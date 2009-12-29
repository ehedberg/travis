require File.dirname(__FILE__) + '/../test_helper'

class BugTest < ActiveSupport::TestCase
  def test_validations
    @model = Bug.new(:title=>"Title", :reported_by=>'Ronaldo', :description=>"The description", :swag=>23)
    assert_valid(:swag, nil, 1, 1.1)
    assert_valid(:title, 'a'*31, 'a'*200)
    assert_invalid(:title, "is too short (minimum is 4 characters)", "")
    assert_invalid(:title, "is too long (maximum is 200 characters)", ('a'*198) + "rgh")
    assert_valid(:description, nil)
    assert_valid(:reported_by, nil)
    assert_valid(:reported_by, 'a'*31, 'a'*200)
    assert_invalid(:reported_by, "is too long (maximum is 200 characters)", ('a'*198) + "rgh")
    assert_invalid(:swag, "is not a number", "hey there")
    assert_invalid(:swag, "must be greater than or equal to 0", -1)
    assert_invalid(:swag, "must be less than 10000", 10000)
    assert_invalid(:severity, "is not a number", "hey there")
    assert_invalid(:severity, "must be greater than or equal to 1", 0)
    assert_invalid(:severity, "must be less than or equal to 4", 5)
    assert_invalid(:priority, "is not a number", "hey there")
    assert_invalid(:priority, "must be greater than or equal to 1", 0)
    assert_invalid(:priority, "must be less than or equal to 4", 5)
    assert_valid(:salesforce_url, nil, '', 'http://www.google.com')
    assert_invalid(:salesforce_url, "does not appear to be valid", 'not_a_url')
    assert_invalid(:salesforce_url, "does not appear to be valid", 27)
    assert_invalid(:salesforce_url, "is too long (maximum is 100 characters)", 'http://www.google.com/' + ('a'*98))
    assert_valid(:salesforce_ticket_nbr, nil, 27)
    assert_invalid(:salesforce_ticket_nbr, "is not a number", "foo")
  end
  
  def test_iteration_relation
    b = Bug.new
    assert b.respond_to?('iteration')
  end
  
  def test_protected_fields
    b = Bug.create(:title=>"Title", :description=>"The description", :swag=>23, :state=>"invalid", :login=>'alsoinvalid')
    assert_nil(b.login)
    assert_equal(:new, b.current_state)
  end
  
  def test_state_model
    User.current_user = users(:quentin)
    b = Bug.create(:title=>"New Bug Title", :description=>"New Bug Description")
    assert_equal("new", b.state)
    assert_nil(b.login)
    assert(b.available_events.include?(:hold))
    assert(b.available_events.include?(:approve))
    assert_equal(2, b.available_events.size)
    b.hold!
    assert_equal('held', b.reload.state)
    assert_nil(b.login)
    b.approve!
    assert_equal('waiting_for_fix', b.reload.state)
    assert_nil(b.login)
    assert(b.available_events.include?(:hold))
    assert(b.available_events.include?(:start))
    assert_equal(2, b.available_events.size)
    b.start!
    assert_equal("in_progress", b.reload.state)
    assert_equal(users(:quentin).login, b.login)
    assert(b.available_events.include?(:stop))
    assert(b.available_events.include?(:finish))
    assert_equal(2, b.available_events.size)
    b.stop!
    assert_equal("waiting_for_fix", b.reload.state)
    assert_nil(b.login)
    b.start!
    b.finish!
    assert_equal("in_qc", b.reload.state)
    assert_equal(users(:quentin).login, b.login)
    assert(b.available_events.include?(:fail))
    assert(b.available_events.include?(:pass))
    assert_equal(2, b.available_events.size)
    b.fail!
    assert_equal("in_progress", b.reload.state)
    assert_equal(users(:quentin).login, b.login)
    b.finish!
    b.pass!
    assert_equal('passed', b.reload.state)
    assert_nil(b.login)

    b2 = Bug.create(:title=>"Another New Bug Title", :description=>"Another New Bug Description")
    b2.approve!
    assert_equal('waiting_for_fix', b2.reload.state)
    b2.hold!
    assert_equal('held', b2.reload.state)
  end

  def test_optimistic_locks
    b = Bug.new(:title=>'fubar', :description=>'baz')
    assert(b.save)
    b2 = Bug.find(b.id)
    b.title='barbar'
    assert(b.save)
    b2.title='mehmeh'
    begin
      b2.save!
      fail "shouldn't work"
    rescue ActiveRecord::StaleObjectError=>x
    end
  end

  def test_taggability
    b = Bug.create(:title=>'mytitle', :description=>'my description')
    assert_equal [], b.tag_list
    b.tag_list = "tag1, Tag2"
    assert(b.save)
    assert_equal(%w(tag1 Tag2), b.tag_list)
  end
  
  def test_severity_text
    b = Bug.new()
    b.severity=1
    assert_equal('Show Stopper', b.severity_text)
    b.severity=2
    assert_equal('Annoying', b.severity_text)
    b.severity=3
    assert_equal('Work-Around Exists', b.severity_text)
    b.severity=4
    assert_equal('Aesthetic', b.severity_text)
  end

  def test_priority_text
    b = Bug.new()
    b.priority=1
    assert_equal('Critical', b.priority_text)
    b.priority=2
    assert_equal('High', b.priority_text)
    b.priority=3
    assert_equal('Medium', b.priority_text)
    b.priority=4
    assert_equal('Low', b.priority_text)
  end
  
  def test_priority
    b = Bug.create!(:title=>"lskfjsdlfkj", :priority=>1)
    assert_equal(1, b.reload.priority)
  end

  def test_mnemonic
    b = Bug.create(:title=>'balh')
    assert_not_nil b.mnemonic
    assert_equal 'BUG-'+b.id.to_s, b.mnemonic
    assert b.save
    assert_equal b.mnemonic, Bug.find(b.id).mnemonic
  end

  def test_audit_record_on_update
    User.current_user = users(:quentin)
    b = Bug.new(:title=>"Title", :description=>"The description", :swag=>23)
    assert b.save
    assert !b.audit_records.empty?
    r = b.audit_records.first
    b2 = Bug.find(b.id)
    assert_equal r, b2.audit_records.first
    b.title="fubar_change"
    assert b.save
    assert_equal 3, b.audit_records.size
    assert_match /\ntitle: \n- Title\n- fubar_change\n/, b.audit_records.last.diff
    b.audit_records.each do |ar|
      assert_equal(User.current_user.login, ar.login)
    end
  end
end

# == Schema Information
# Schema version: 20090612194131
#
# Table name: bugs
#
#  id           :integer         not null, primary key
#  title        :string(200)
#  description  :text
#  reported_by  :string(200)
#  login        :string(50)
#  state        :string(20)      default("new"), not null
#  swag         :decimal(4, 2)
#  severity     :integer
#  priority     :integer
#  mnemonic     :string(10)
#  completed_at :date
#  iteration_id :integer
#  lock_version :integer         default(0), not null
#  created_at   :datetime
#  updated_at   :datetime
#

