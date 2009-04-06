require File.dirname(__FILE__) + '/../../spec_helper'

describe "app layout" do
  it "should have a footer logout link if logged in" do
    session[:user_id]=1
    render 'layouts/application'
    response.should have_tag '#footer' do 
      with_tag "a[href=?]", logout_path
      with_tag "a[href=?]", signup_path, 0
      with_tag "a[href=?]", login_path, 0
    end
  end
  it "should have a signup link if not logged in" do
    session[:user_id]=nil
    render 'layouts/application'
    response.should have_tag '#footer' do 
      with_tag "a[href=?]", signup_path, "Create Account"
      with_tag "a[href=?]", login_path, "Login"
    end
  end
  it "should not have a signup link if not logged in" do
    session[:user_id]=nil
    render 'layouts/application'
    response.should have_tag '#footer' do 
      with_tag "a[href=?]", signup_path, "Create Account"
      with_tag "a[href=?]", login_path, "Login"
      with_tag "a[href=?]", logout_path, 0
    end
  end

end
