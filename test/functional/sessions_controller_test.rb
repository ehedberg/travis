require File.dirname(__FILE__)+'/../test_helper'

class SessionsControllerTest < ActionController::TestCase

  def test_routes
    assert_routing "/login", :controller=>"sessions", :action=>"new"
    assert_recognizes({:controller=>"sessions",:action=>"create"}, :path=>"/session", :method=>"post")
    assert_recognizes({:controller=>"sessions",:action=>"destroy"}, :path=>"/session", :method=>"delete")
  end

  def test_create
    @request.session[:return_to]='blah'
    User.expects(:authenticate).with('blah', 'foo').returns users(:quentin)
    post :create, {:login=>'blah', :password=>'foo'} 
    assert_response :redirect
    assert_redirected_to '/blah'
    assert_equal users(:quentin).id, session[:user_id]
  end
  def test_redirects_default_no_flash
    post :create, {:login=>'quentin', :password=>'monkey'}
    assert_response :redirect
    assert_redirected_to root_path
  end
  def test_flashback
    @request.session[:return_to]='/iterations'
    post :create, {:login=>'quentin', :password=>'monkey'}
    assert_response :redirect
    assert_redirected_to iterations_path
  end

  def test_destroy
    @request.session[:user_id]='blah'
    delete :destroy
    assert_nil session[:user_id]
    assert_response :redirect
    assert_redirected_to root_path
  end

  def test_new
    get :new, :login=>'mml'
    assert_response :success
    assert_template 'new'

    assert_select "form[action=?][method=post]", session_path do
      assert_select "input[type=text][name=login]"
      assert_select "input[type=submit]"
    end
  end

  def test_logout_button_footer
    @request.session[:user_id]=1
    get :new
    assert_select "a[href=?]", logout_path, "Logout"
  end

end
