class AuthController < ApplicationController

  def oauth
    request_token = Rsss::Oauth.consumer.get_request_token(
      :oauth_callback=>"http://#{request.host_with_port}/auth/oauth_callback")
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    return redirect_to request_token.authorize_url
  end

  def oauth_callback
    request_token = OAuth::RequestToken.new(Rsss::Oauth.consumer,
      session[:request_token], session[:request_token_secret])

    access_token = request_token.get_access_token({},
      :oauth_token=>params[:oauth_token], :oauth_verifier=>params[:oauth_verifier])

    response = Rsss::Oauth.consumer.request(:get,
      '/account/verify_credentials.json',
      access_token, {:scheme=>:query_string})

    case response
    when Net::HTTPSuccess
      @user_info = JSON.parse(response.body)
      raise unless @user_info['screen_name']
    else
      RAILS_DEFAULT_LOGGER.error 'Failed to get user info via OAuth'
      raise
    end
    
    user = User.find(:first, :conditions=>{:oauth_user_id=>@user_info['id'].to_i}) || User.new(:oauth_user_id=>@user_info['id'])
    user.screen_name = @user_info['screen_name']
    user.oauth_token = access_token.token
    user.oauth_secret = access_token.secret
    user.token = (Digest::SHA1.new<<access_token.token).to_s 
    user.save

    session[:token] = user.token
    return redirect_to '/dashboard'

  rescue
    flash[:notice] = 'Authentication failed'
    return redirect_to :action=>:failure
  end

  def failure; end

  def signout
    session[:token] = nil
    return redirect_to '/'
  end
end
