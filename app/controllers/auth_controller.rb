class AuthController < ApplicationController

  def self.consumer
    OAuth::Consumer.new(
      Rsss::OAUTH_CONSUER_KEY,
      Rsss::OAUTH_CONSUMER_SECRET,
      {site: 'http://twitter.com'})
  end

  def oauth
    request_token = self.class.consumer.get_request_token(
      oauth_callback: "http://#{request.host_with_port}/auth/oauth_callback")
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    return redirect_to request_token.authorize_url
  end

  def oauth_callback
    consumer = self.class.consumer
    request_token = OAuth::RequestToken.new(consumer,
      session[:request_token], session[:request_token_secret])

    access_token = request_token.get_access_token({},
      oauth_token: params[:oauth_token], oauth_verifier: params[:oauth_verifier])

    response = consumer.request(:get,
      '/account/verify_credentials.json',
      access_token, {:scheme=>:query_string})

    case response
    when Net::HTTPSuccess
      @user_info = JSON.parse(response.body)
      unless @user_info['screen_name']
        flash[:notice] = 'Authentication failed'
        return redirect_to :action=>:failure
      end
    else
      RAILS_DEFAULT_LOGGER.error 'Failed to get user info via OAuth'
      flash[:notice] = 'Authentication failed'
      return redirect_to :action=>:failure
    end
    
    user = User.find(:first, :conditions=>{:screen_name=>@user_info['screen_name']}) || User.new(:screen_name=>@user_info['screen_name'])
    user.oauth_token = access_token.token
    user.oauth_secret = access_token.secret
    user.token = (Digest::SHA1.new<<access_token.token).to_s 
    user.save
    user.create_histories rescue nil

    session[:token] = user.token
    return redirect_to '/dashboard'
  end

  def failure; end
end
