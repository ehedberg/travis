require File.dirname(__FILE__) + '/../test_helper'

class AuditRecordTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    Session.current_login='fubar'
  end
  def test_create
    a = AuditRecord.new :diff=>'test',:auditable=>stories(:one),:login=>'fubar'
    assert a.save
    afound = AuditRecord.find(a.id)
    assert_not_nil afound.diff
    assert_equal afound.diff, a.diff
    assert_not_nil afound.auditable
    assert_equal afound.auditable, a.auditable
    assert_not_nil afound.login
    assert_equal afound.login, a.login
  end
  def test_validations
    @model = AuditRecord.new :diff=>'test', :auditable=>stories(:one), :login=>'fubar'
    [:diff, :login].each do |n|
      assert_invalid(n, "can't be blank", nil, '')
    end

  end

  def test_create_with_task
    a = AuditRecord.new :diff=>'test_task', :auditable=>tasks(:one),:login=>'fooTask'
    assert a.save
    
    afound = AuditRecord.find(a.id)
    assert_not_nil afound.diff
    assert_equal afound.diff, a.diff
    assert_not_nil afound.auditable
    assert_equal afound.auditable, a.auditable
    assert_not_nil afound.login
    assert_equal afound.login, a.login
    assert_equal afound.auditable, tasks(:one)

  end

  def test_history_hash
    s = Story.new(:nodule=>'fubar', :title=>'bleh', :description=>'meh')
    assert s.save!
    assert s.audit_records.first.diff_to_hash.kind_of?(Hash)
    h = s.audit_records.first.diff_to_hash
    assert_equal 1, h.keys.size
    assert_equal :self, h.keys.first
    s.reload
    s.nodule="fubar2"
    assert s.save!
    s.audit_records.reload
    assert_equal 3, s.audit_records.size
    h = s.audit_records.last.diff_to_hash
    assert_equal 2, h.keys.size
    assert_equal :nodule, h.keys.first.to_sym
  end


end
