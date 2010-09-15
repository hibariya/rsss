class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def load_user(username)
    if @user = User.find(:first, :conditions=>{:screen_name=>username})
      @user_info = Rsss::Oauth.user_info @user.oauth_token, @user.oauth_secret
    end
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
