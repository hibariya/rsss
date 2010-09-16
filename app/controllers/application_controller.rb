class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def load_user(username)
    @user = User.find(:first, :conditions=>{:screen_name=>username})
  end

  def self.check_signin
    lambda { 
      if session[:token]
        load_user User.find_by_token(session[:token]).screen_name rescue nil
      end

      if @user.nil?
        flash[:notice] = "Authentication failed"
        return redirect_to :controller=>:auth, :action=>:failure
      end
    }
  end
end
