class SessionsController < ApplicationController

  def new
  end

  def create
    session[:login]=params[:login]
    redirect_to stories_path
  end
  def destroy
    session[:login]=nil
    redirect_to stories_path
  end
end
