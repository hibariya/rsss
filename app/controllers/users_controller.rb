class UsersController < ApplicationController
  before_filter ApplicationController.check_signin
  
  def update
    session_user.site = params[:user][:site]
    session_user.description = params[:user][:description]
    if session_user.valid?
      session_user.save
      flash[:notice] = "Profile has been changed"
    else
      flash[:notice] = session_user.errors.first.last
    end
    return redirect_to '/dashboard'
  end

end
