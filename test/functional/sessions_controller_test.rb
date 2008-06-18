require File.dirname(__FILE__)+'/../test_helper'

class SessionsControllerTest < ActionController::TestCase

  def test_routes
    assert_routing "/session/new", :controller=>"sessions", :action=>"new"
    assert_recognizes({:controller=>"sessions",:action=>"create"}, :path=>"/session", :method=>"post")
    assert_recognizes({:controller=>"sessions",:action=>"destroy"}, :path=>"/session", :method=>"delete")
  end

  def test_create
    post :create, :login=>'blah'
    assert_response :redirect
    assert_redirected_to stories_path
    assert_equal 'blah', session[:login]
    assert_equal 'blah', Session.current_login
  end
  def xtest_flashback
    @response.flash[:back]='/iterations'
    post :create, :login=>'blah'
    assert_response :redirect
    assert_redirected_to iterations_path
  end

  def test_destroy
    @request.session[:login]='blah'
    delete :destroy
    assert_nil session[:login]
    assert_nil Session.current_login
    assert_response :redirect
    assert_redirected_to stories_path
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
    @request.session[:login]='foo'
    get :new
    assert_select "a[href=?]", session_path, "Logout"
  end

end
