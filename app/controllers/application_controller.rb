# -*- coding: utf-8 -*-

class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  #rescue_from :with => :application_error

  def current_user
    @current_user ||= User.where(:token => session[:user_token]).first
  end

  def current_user=(user)
    session[:user_token] = user.token
    @current_user = user
  end

  def signed_in?
    !!current_user
  end

  def require_user
    unless signed_in?
      render :controller => :sessions,
             :action     => :failure,
             :status     => 403
      return false
    end
  end

  private
  
    def application_error(e)
      ErrorLog.add e
      respond_to do |format|
        format.html{ render :controller => :index, :action => :failure }
        format.xml{ render :controller => :index, :action => :failure, :layout => false }
      end
    end
end
