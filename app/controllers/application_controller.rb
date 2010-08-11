class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def load_user(username)
    if @user = User.find(:first, :conditions=>{:screen_name=>username})
      access_token = OAuth::AccessToken.new(AuthController.consumer, @user.oauth_token, @user.oauth_secret)
      @user_info = JSON.parse(access_token.get('/account/verify_credentials.json').body)
    end
  end

  def self.check_admin
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
