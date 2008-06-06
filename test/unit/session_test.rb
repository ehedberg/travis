require File.dirname(__FILE__) + '/../test_helper'

class SessionTest < ActiveSupport::TestCase

  def test_session_model_exists
    assert(Session.respond_to?("current_login"))
    assert(Session.respond_to?("current_login="))
  end

end
