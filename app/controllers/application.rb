# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e763e694b24cbffe0c373f235e368b04'
  private
  def requires_login
    if session[:login]
      Session.current_login||=session[:login]
      return true
    else
      redirect_to new_session_path unless session[:login]
      return false
    end
  end
end
