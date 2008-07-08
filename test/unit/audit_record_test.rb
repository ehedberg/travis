require File.dirname(__FILE__) + '/../test_helper'

class AuditRecordTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_create
    a = AuditRecord.new :diff=>'test',:story=>stories(:one),:login=>'fubar'
    assert a.save
    afound = AuditRecord.find(a.id)
    assert_not_nil afound.diff
    assert_equal afound.diff, a.diff
    assert_not_nil afound.story
    assert_equal afound.story, a.story
    assert_not_nil afound.login
    assert_equal afound.login, a.login
  end
  def test_validations
    @model = AuditRecord.new :diff=>'test', :story=>stories(:one), :login=>'fubar'
    [:diff, :story_id, :login].each do |n|
      assert_invalid(n, "can't be blank", nil, '')
    end

  end


end
