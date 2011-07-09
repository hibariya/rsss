class SessionsController < ApplicationController
  protect_from_forgery except: :create

  def new
    redirect_to '/auth/twitter'
  end

  def create
    auth = request.env["omniauth.auth"].symbolize_keys

    if a = Authentication.where(auth.slice(:provider, :uid)).first
      session[:user_id] = authentication.user_id
      redirect_to session.delete(:return_to) || dashboard_path

    else
      # new user
    end
  end

  def destroy
    @current_user = nil
    reset_session
    redirect_to signin_path, notice: 'You have signed out successfully'
  end

  def failure
    flash[:error] = "Authentication error: #{params[:message].humanize}"
    redirect_to root_path
  end
end
