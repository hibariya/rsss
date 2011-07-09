class SessionsController < ApplicationController
  protect_from_forgery except: :create

  before_filter :authenticate_user!, only: [:destroy]

  def new
    redirect_to '/auth/twitter'
  end

  def create
    auth = request.env["omniauth.auth"].symbolize_keys

    if a = Authentication.where(auth.slice(:provider, :uid)).first
      session[:user_id] = a.user_id
    else
      user = User.create!(name: auth[:user_info][:nickname])
      Authentication.create! user: user do |a|
        a.attributes = auth.slice(:provider, :uid)
        a.attributes = auth[:user_info].symbolize_keys.slice(:name, :description)
      end

      session[:user_id] = user.id
    end

    redirect_to session.delete(:return_to) || dashboard_path
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'You have signed out successfully'
  end

  def failure
    flash[:error] = "Authentication error: #{params[:message].humanize}"
    redirect_to root_path
  end
end
