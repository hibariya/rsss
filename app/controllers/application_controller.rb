class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def session_user
    @session_user ||= session[:token] && User.find_by_token(session[:token]) rescue nil
  end

  def self.check_signin
    lambda { 
      if session_user.nil?
        flash[:notice] = "Authentication failed"
        return redirect_to :controller=>:auth, :action=>:failure
      end
    }
  end
end
