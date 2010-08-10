class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  protected
  def load_user(username)
    if @user = User.find(:first, :conditions=>{:screen_name=>username})
      access_token = OAuth::AccessToken.new(AuthController.consumer, @user.oauth_token, @user.oauth_secret)
      @user_info = JSON.parse(access_token.get('/account/verify_credentials.json').body)
    end
  end
end
