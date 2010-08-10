class AuthController < ApplicationController

  def self.consumer
    OAuth::Consumer.new(
      'key',
      'secret',
      {:site => 'http://twitter.com'}
    )
  end

  def oauth
  end

  def oauth_callback
  end

end
