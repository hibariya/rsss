class AuthController < ApplicationController

  def self.consumer
    OAuth::Consumer.new(
      'LDoKK9JyZvcAamOEeoLoQ',
      '7SCkQoXtYfzLplVH28ucQb29sPhogsGhSDpN2bCg',
      {:site => 'http://twitter.com'}
    )
  end

  def oauth
  end

  def oauth_callback
  end

end
