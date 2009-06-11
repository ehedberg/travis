require File.dirname(__FILE__) + '/../test_helper'
require 'passwords_controller'

class PasswordsControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper
  
  def test_new
    post :new
    assert_response :success
    assert_template "new"
  end
  
  def test_create
    user = users(:quentin)
    assert_nil(user.password_reset_code)
    post :create, :email => user.email
    assert_equal("A password reset link has been sent to #{user.email}", flash[:notice])
    assert_response :redirect
    assert_redirected_to new_session_path
    assert_not_nil(user.reload.password_reset_code)
  end

  def test_create_user_not_found
    post :create, :email => "bogus@example.com"
    assert_equal("Could not find a user with that email address.", flash[:notice])
    assert_response :success
    assert_template "new"
  end
  
  def test_edit
    user = users(:quentin)
    user.forgot_password
    user.save
    post :edit, :id => user.password_reset_code
    assert assigns(:user)
    assert_response :success
    assert_template "edit"
  end

  def test_edit_password_reset_code_missing
    post :edit
    assert_response :success
    assert_template "new"
  end

  def test_edit_password_reset_code_not_found
    user = users(:quentin)
    user.forgot_password
    user.save
    post :edit, :id => '12'
    assert_equal("Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)", flash[:notice])
    assert_redirected_to new_session_path
  end
end