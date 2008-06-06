class SessionsController < ApplicationController

  def new
  end

  def create
    session[:login]=params[:login]
    Session.current_login=session[:login]
    redirect_to stories_path
  end

  def destroy
    session[:login]=nil
    Session.current_login=nil
    redirect_to stories_path
  end

end
