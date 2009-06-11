class PasswordsController < ApplicationController
  layout 'sessions'
 
  # Forgot password action
  def create
    if @user = User.find_for_forget(params[:email])
      @user.forgot_password
      @user.save      
      flash[:notice] = "A password reset link has been sent to #{@user.email}"
      redirect_to new_session_path
    else
      flash[:notice] = "Could not find a user with that email address."
      render :template=>"passwords/new"
    end  
  end
  
  # Action triggered by clicking on the /reset_password/:id link recieved via email
  # Makes sure the id code is included
  # Checks that the id code matches a user in the database
  # Then if everything checks out, shows the password reset fields
  def edit
    if params[:id].nil?
      render :template=>"passwords/new"
    else
      @user = User.find_by_password_reset_code(params[:id]) if params[:id]
      raise if @user.nil?
    end
  rescue
    flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)"
    redirect_to new_session_path
  end
    
  # Reset password action /reset_password/:id
  # Checks once again that an id is included and makes sure that the password field isn't blank
  def update
    if params[:id].nil?
      render :template=>"passwords/new"
      return
    end
    if params[:password].blank?
      flash[:notice] = "Password field cannot be blank."
      render :action => 'edit', :id => params[:id]
      return
    end
    
    @user = User.find_by_password_reset_code(params[:id]) if params[:id]
    raise if @user.nil?
    return if @user unless params[:password]
    
    if (params[:password] == params[:password_confirmation])
      @user.password_confirmation = params[:password_confirmation]
      @user.password = params[:password]
      @user.reset_password        
      flash[:notice] = @user.save ? "Password reset." : "Password not reset."
    else
      flash[:notice] = "Password mismatch."
      render :action => 'edit', :id => params[:id]
      return
    end  
    redirect_to new_session_path
  rescue
    flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)"
    redirect_to new_session_path
  end
end
