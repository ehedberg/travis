require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  def test_story_taggable
    s= Story.find(:first)
    assert_equal [],s.tag_list
    s.tag_list="Stupid, lame"
    assert s.save
    assert_equal %w(Stupid lame), s.tag_list
  end
  def test_mnemonic
    s = Story.create(:nodule=>'ab -c ?.%   d', :title=>'balh')
    assert_not_nil s.mnemonic
    assert_equal 'ABCD-'+s.id.to_s, s.mnemonic
    assert s.save
    assert_equal s.mnemonic, Story.find(s.id).mnemonic
    s2 = Story.create(:nodule=>'ab -cd?.%   d', :title=>'balh2')
    assert s2.save!
    s2.mnemonic=s.mnemonic
    assert !s2.save
    assert_not_nil s2.errors.on(:mnemonic)
    s2 = Story.create(:title=>'nomn')
  end
  def test_state_changed_on_task_remove
    s = Story.create(:title=>'fubar', :description=>'basz', :nodule=>'nodule')
    t1 = Task.new(:title=>'fubar', :description=>'t1')
    t2 = Task.new(:title=>'fubar', :description=>'t2')
    s.tasks << t1
    s.tasks << t2
    t1.start!
    t1.finish!
    s.reload
    assert_equal :in_progress, s.current_state
    assert_equal :complete, t1.current_state
    assert_equal :new, t2.current_state
    s.tasks.delete(t2)
    assert_equal :in_qc, s.current_state
  end

  def test_state_changed_on_task_add_in_prog
    s = Story.new(:title=>'fubar', :description=>'basz', :nodule=>'nodule')
    assert s.save
    t = s.tasks.create(:title=>'a task', :description=>'the task')
    assert t.valid?
    assert !t.new_record?
    assert_equal s, t.stories.first
    t.start!
    t.reload
    s.reload
    assert_equal :in_progress, t.current_state
    assert_equal :in_progress, s.current_state
    s2 = Story.new(:title=>'s23e', :description=>'blah', :nodule=>'nodule')
    assert s2.save!
    assert_equal :new, s2.current_state
    s2.tasks << t
    s2.reload
    assert_equal :in_progress, s2.current_state
  end

  def test_has_nodule_field
    assert_nil  Story.new.nodule
  end

  def test_cant_add_task_to_passed_story
    s = Story.create(:title=>'fubar', :description=>'baz', :nodule=>'nodule')
    assert_equal :new, s.current_state
    t=s.tasks.create(:title=>'baz', :description=>'bleh')
    assert :new, s.current_state
    t.start!
    s.reload
    assert_equal :in_progress, s.current_state
    s.reload
    t.finish!
    s.reload
    assert_equal :in_qc, s.current_state
    s.pass!
    s.reload
    assert_equal :passed, s.current_state
    begin
      t2=s.tasks.create(:title=>'dang', :description=>'bleh2')
      fail "shouldn't work"
    rescue ActiveRecord::ActiveRecordError=>x
    end
  end
  def test_optimistic_locks
    t = Story.new({:title=>'fubar', :description=>'baz', :nodule=>'nodule'})
    assert t.save
    t2 = Story.find(t.id)

    t.title='barz'
    assert t.save!
    t2.title='mehz'
    begin
      t2.save
      fail "shouldn't work"
    rescue ActiveRecord::StaleObjectError=>x
    end
  end
  def test_find_all_stories
    story_list = Story.find(:all)
    assert_not_nil(story_list)
    assert(!story_list.empty?, "no stories found")
  end

  def test_task_relation
    s = Story.new
    assert_not_nil(s.tasks)
  end
  def test_has_completed_at
    s= Story.new
    assert(s.respond_to?(:completed_at))
  end

  def test_has_state
    s= Story.new
    assert(s.respond_to?(:state))
  end
  def test_iteration_relation
    s = Story.new

    assert s.respond_to?("iteration")
  end
  def test_sets_completed_at_on_pass
    s = Story.create(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'required')
    t = s.tasks.create(:title=>'fubario', :description=>'bazio')
    assert s.valid? and t.valid?
    assert_nil s.completed_at
    t.start!
    t.finish!
    s.reload
    s.pass!
    s.reload
    assert_equal :passed, s.current_state
    assert_equal :complete, t.current_state
    assert_equal Date.today, s.completed_at
  end

  def test_validation
    @model = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'required')
    assert_valid(:swag, nil, 1, 1.1)
    assert_valid(:title, 'a'*31, 'a'*200)
    assert_invalid(:nodule, "can't be blank", "", nil)
    assert_invalid(:swag, "is not a number", "hey there")
    assert_invalid(:swag, "must be greater than or equal to 0", -1)
    assert_invalid(:swag, "must be less than 10000", 10000)
    assert_valid(:description, nil)
    assert_invalid(:title, "is too short (minimum is 4 characters)", "")
    assert_invalid(:title, "is too long (maximum is 200 characters)", ('a'*198) + "rgh")
    assert_valid(:salesforce_url, nil, '', 'http://www.google.com')
    assert_invalid(:salesforce_url, "does not appear to be valid", 'not_a_url')
    assert_invalid(:salesforce_url, "does not appear to be valid", 27)
    assert_invalid(:salesforce_url, "is too long (maximum is 100 characters)", 'http://www.google.com/' + ('a'*98))
    assert_valid(:salesforce_ticket_nbr, nil, 27)
    assert_invalid(:salesforce_ticket_nbr, "is not a number", "foo")
  end

  def test_unique_title
    @model = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    @model.save!
    @model2 = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert !@model2.save
    assert_equal "has already been taken", @model2.errors.on(:title)
  end

  def test_add_task
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save
    assert_equal :new, s.current_state
    t = s.tasks.create(:title=>'foo', :description=>'bar')
    assert !t.new_record?
    t.start!
    s.reload
    assert_equal :in_progress, t.current_state
    assert_equal :in_progress,  s.current_state
  end

  def test_tasks_all_stopped_moves_from_in_prog_to_new
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save
    assert_equal :new, s.current_state
    t = s.tasks.create(:title=>'foo', :description=>'bar')
    t2 = s.tasks.create(:title=>'fubar', :description=>'bar')
    assert !t.new_record?
    assert !t2.new_record?

    t2.start!
    t2.stop!
    assert_equal :new, t2.current_state

    t.start!
    assert_equal :in_progress, t.current_state
    t.stop!
    assert_equal :new, t.current_state

    s.reload
    assert_equal :new, t.current_state
    assert_equal :new, t.current_state
    assert_equal :new,  s.current_state
  end
  
  def test_delete_last_incomplete_task_moves_to_qc
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save
    assert_equal :new, s.current_state
    t = s.tasks.create(:title=>'foo', :description=>'bar')
    t2 = s.tasks.create(:title=>'fubar', :description=>'bar')
    assert !t.new_record?
    assert !t2.new_record?

    t2.start!
    t2.finish!
    assert_equal :complete, t2.current_state
    assert_equal :in_progress, s.reload.current_state
    
    t.destroy
    assert_equal :complete, t2.reload.current_state
    assert_equal :in_qc, s.reload.current_state
  end

  def test_delete_last_in_process_task_moves_to_new
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save
    assert_equal :new, s.current_state
    t = s.tasks.create(:title=>'foo', :description=>'bar')
    t2 = s.tasks.create(:title=>'fubar', :description=>'bar')
    assert !t.new_record?
    assert !t2.new_record?

    t2.start!
    assert_equal :in_progress, t2.reload.current_state
    assert_equal :new, t.reload.current_state
    assert_equal :in_progress, s.reload.current_state
    
    t2.destroy
    assert_equal :new, t.reload.current_state
    assert_equal :new, s.reload.current_state
  end

  def test_some_Tasks_stopped_doesnt_transit_to_new
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save
    assert_equal :new, s.current_state
    t = s.tasks.create(:title=>'foo', :description=>'bar')
    t2 = s.tasks.create(:title=>'fubar', :description=>'bar')
    assert !t.new_record?
    t2.start!
    t2.finish!
    t.start!
    t.stop!
    s.reload
    assert_equal :new, t.current_state
    assert_equal :complete, t2.current_state
    assert_equal :in_progress,  s.current_state
  end
  def test_task_changed_in_qc_moves_to_inprogress_if_some_not_complete
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save

    assert_equal :new, s.reload.current_state
    t = s.tasks.create(:title=>'foo', :description=>'bar')
    t2 = s.tasks.create(:title=>'fubar', :description=>'bar')
    assert !t.new_record?
    assert !t2.new_record?
    t2.start!
    t2.finish!

    t.start!
    t.finish!
    s.reload
    assert_equal :in_qc, s.current_state

    t2.reopen!
    assert :in_progress, t2.current_state

  end
  def test_some_task_changed_in_prog_toqc
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save
    assert_equal :new, s.current_state
    t = s.tasks.create(:title=>'foo', :description=>'bar')
    t2 = s.tasks.create(:title=>'fubar', :description=>'bar')
    assert !t.new_record?
    t2.start!
    assert :in_progress, s.reload.current_state
    assert :in_progress, t.current_state
    t2.finish!
    assert :complete, t2.current_state
    t.start!
    assert :in_progress, t.current_state
    t.finish!
    assert :in_qc, s.reload.current_state
    assert :complete, t.current_state
    assert :complete, t2.current_state


    s.reload
    assert_equal :in_qc,  s.current_state
  end

  def test_state_model
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save
    t=s.tasks.create( :title=>"New Task Title", :description=>"New Task Description")
    assert_equal :new,  t.current_state
    assert(s.save)
    assert_equal(:new, s.current_state)
    t.start!
    assert_equal :in_progress, t.stories.first.current_state
    s.reload
    assert_equal :in_progress, t.current_state
    assert_equal :in_progress, s.current_state

    t2=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description")
    assert !t2.new_record?
    assert !s.new_record?
    assert_equal :new, t2.current_state
    t2.start!
    assert_equal :in_progress, t2.current_state
    t.finish!
    assert_equal :complete, t.current_state
    assert_equal :in_progress, t2.current_state
    assert_equal :in_progress, s.current_state 
    t2.start!
    s.reload
    assert_equal :in_progress, t2.current_state
    assert_equal :complete, t.current_state

    t2.reload
    s.reload
    t2.finish!
    s.reload
    assert_equal :in_qc, s.current_state
    assert_equal :complete, t2.current_state
    t2.reopen!
    assert :in_progress, s.reload.current_state
  end

  def test_state_is_protected
    s = Story.create(:title=>"Title", :description=>"The description", :swag=>23, :state=>"invalid", :nodule=>'nodule')

    assert_equal :new, s.current_state
  end
  def test_passed_then_task_reopen_to_inprog
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    s.save!
    t=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description")
    assert_equal :new, s.current_state
    t.start!
    s.reload
    t.reload
    assert_equal :in_progress, s.current_state
    t.finish!
    s.reload
    t.reload
    assert_equal :in_qc, s.current_state
    s.pass!
    s.reload
    t.reload
    assert_equal :passed, s.current_state
    t.reopen!
    t.reload
    assert_equal :in_progress, t.current_state
    s.reload
    assert_equal :in_progress, s.current_state
  end

  def test_happy_path
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    s.save!
    t=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description")
    assert_equal :new, s.current_state
    t.start!
    s.reload
    assert_equal :in_progress, s.current_state
    t.finish!
    s.reload
    assert_equal :in_qc, s.current_state
    s.pass!
    s.reload
    assert_equal :passed, s.current_state
  end
  def test_qc_to_failed
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    s.save!
    t=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description")
    assert_equal :new, s.current_state
    t.start!
    s.reload
    assert_equal :in_progress, s.current_state
    t.finish!
    s.reload
    assert_equal :in_qc, s.current_state
    s.fail!
    s.reload
    assert_equal :failed, s.current_state
  end
  def test_new_to_in_prog
    s = Story.create(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    t=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description")
    t.start!
    s.reload
    assert_equal :in_progress, s.current_state
  end
  
  def test_assignee
    s = Story.create(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    
    t=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description", :login=>'billy')
    t3=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description", :login=>'billy')
    assert_equal('', s.assignee)
    
    t.start!
    t3.start!
    
    assert s.reload
    assert_equal(:in_progress, s.current_state)
    assert_equal('billy', s.assignee)
    t2=s.tasks.create(:title=>"Another Title2", :description=>"Another Task Description", :login=>'billysmom')
    t2.start!
    assert s.reload    
    assert_equal('billy, billysmom', s.assignee)
    t.finish!
    t3.finish!
    assert s.reload
    assert_equal('billysmom', s.assignee)
    
    t2.finish!
    assert s.reload
    assert_equal(:in_qc, s.current_state)
    assert_equal('billy, billysmom', s.assignee)    
  end

  def test_failed_to_in_progress
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    s.save!
    t=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description")
    t2=s.tasks.create(:title=>"Another Title2", :description=>"Another Task Description")
    assert_equal :new, s.current_state
    t.start!
    t2.start!
    t2.reload
    t.reload
    s.reload
    assert_equal :in_progress, s.current_state
    t.finish!
    t2.finish!
    s.reload
    t.reload
    t2.reload
    assert_equal :in_qc, s.current_state
    s.fail!
    s.reload
    t.reload
    t2.reload
    assert_equal :failed, s.current_state
    assert_equal :complete, t.current_state
    assert_equal :complete, t2.current_state
    t.reopen!
    s.reload
    t.reload
    t2.reload
    assert_equal :complete, t2.current_state
    assert_equal :in_progress, t.current_state
    assert_equal :in_progress, s.current_state
  end

  def test_audit_record
    s = stories(:one)
    assert_not_nil s.audit_records
  end

  def test_audit_record_on_create
    User.current_user = users(:quentin)
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23, :nodule=>'nodule')
    assert s.save
    assert !s.audit_records.empty?
    r = s.audit_records.first

    s = Story.find(s.id)
    assert_equal s.audit_records.first, r

    s.title="fubar_change"
    assert s.save
    assert_equal 3, s.audit_records.size
    assert_match /\ntitle: \n- Title\n- fubar_change\n/, s.audit_records.last.diff
    s.audit_records.each do |ar|
      assert_equal(User.current_user.login, ar.login)
    end
  end
end

# == Schema Information
# Schema version: 20090612194131
#
# Table name: stories
#
#  id              :integer         not null, primary key
#  title           :string(200)     not null
#  description     :text
#  swag            :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  iteration_id    :integer
#  state           :string(20)      default("new"), not null
#  completed_at    :date
#  lock_version    :integer         default(0)
#  nodule          :string(200)
#  mnemonic        :string(10)
#  cached_tag_list :string(255)
#

