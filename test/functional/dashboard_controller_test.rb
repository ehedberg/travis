require File.dirname(__FILE__)+'/../test_helper'

class DashboardControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:iteration)
    i = assigns(:iteration)
    assert i.start_date <= Date.today
    assert i.end_date >= Date.today
    assert_equal i, iterations(:current)
  end
  def test_routin
    assert_routing("/", :controller=>'dashboard', :action=>'index')
  end
end
