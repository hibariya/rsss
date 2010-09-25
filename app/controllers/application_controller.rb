class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def specified_controllers; %w(auth dashboard user sites users index) end
  def session_user
    @session_user ||= session[:token] && User.by_token(session[:token]).first rescue nil
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
