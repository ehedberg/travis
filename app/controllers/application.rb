# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'authenticated_system'
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time
  alias :requires_login :login_required 
  after_filter :clear_current_user

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
#  protect_from_forgery  :secret => 'e763e694b24cbffe0c373f235e368b04'

  def clear_current_user
    User.current_user = nil
  end
end
