require File.dirname(__FILE__)+'/../test_helper'

class DashboardControllerTest < ActionController::TestCase
  def setup
    @request.session[:user_id]=1
  end
  def test_requires_login
    @request.session[:user_id]=nil
    get :index
    assert_response :redirect
    assert_redirected_to new_session_path
    @request.session[:user_id]=1
    get :index
    assert_response :success
    assert_template 'index'
  end
  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:iteration)
    i = assigns(:iteration)
    assert i.start_date <= Date.today
    assert i.end_date >= Date.today
    assert_equal i, iterations(:iter_current)
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

  def test_prediction
    get :index
    assert_response :success
    assert assigns(:prediction)
    assert_select "td#prediction"
  end
end
