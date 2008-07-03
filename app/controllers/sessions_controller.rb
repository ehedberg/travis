class SessionsController < ApplicationController

  def new
    flash[:back] = flash[:back]
  end

  def create
    session[:login]=params[:login]
    Session.current_login=session[:login]
    redirect_to flash[:back] ? flash[:back] : root_path
  end

  def destroy
    session[:login]=nil
    Session.current_login=nil
    redirect_to root_path
  end

end
