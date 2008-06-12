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
    assert assigns(:next_iteration)
    assert assigns(:prev_iteration)
  end
  def test_routin
    assert_routing("/", :controller=>'dashboard', :action=>'index')
  end
  def test_works_w_no_iterations
    Iteration.destroy_all
    assert_equal 0, Iteration.count
    get :index
    assert_response:success
    assert_template 'empty'
  end
end
