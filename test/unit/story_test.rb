require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase

  def test_has_area_field
    assert_nil  Story.new.area
  end

  def test_cant_add_task_to_passed_story
    s = Story.create({:title=>'fubar', :description=>'baz'})
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
    t = Story.new({:title=>'fubar', :description=>'baz'})
    assert t.save
    t2 = Story.find(t.id)

    t.title='bar'
    assert t.save
    t2.title='meh'
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

  def test_validation
    @model = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
    assert_valid(:swag, nil, 1, 1.1)
    assert_invalid(:swag, "is not a number", "hey there")
    assert_invalid(:swag, "must be greater than or equal to 0", -1)
    assert_invalid(:swag, "must be less than 10000", 10000)
    assert_valid(:description, nil)
    assert_invalid(:title, "is too short (minimum is 1 characters)", "")
    assert_invalid(:title, "is too long (maximum is 200 characters)", ('a'*198) + "rgh")
  end

  def test_unique_title
    @model = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
    @model.save!
    @model2 = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
    assert !@model2.save
    assert_equal "has already been taken", @model2.errors.on(:title)
  end

  def test_add_task
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
  def test_some_Tasks_stopped_doesnt_transit_to_new
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
    s = Story.create(:title=>"Title", :description=>"The description", :swag=>23, :state=>"invalid")

    assert_equal :new, s.current_state
  end
  def test_passed_then_task_reopen_to_inprog
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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
    s = Story.create(:title=>"Title", :description=>"The description", :swag=>23)
    t=s.tasks.create(:title=>"Another Title", :description=>"Another Task Description")
    t.start!
    s.reload
    assert_equal :in_progress, s.current_state

  end

  def test_failed_to_in_progress
    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)
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



end
