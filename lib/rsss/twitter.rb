# -*- encoding: utf-8 -*-

module Rsss
  class Twitter
    class << self
      def consumer
        @consumer ||= ::OAuth::Consumer.new(
          Rsss::OAUTH_CONSUMER_KEY,
          Rsss::OAUTH_CONSUMER_SECRET,
          {:site=>'https://twitter.com'})
      end

      def user_info(token, secret)
        ::JSON.parse access_token(token, secret). 
          get('/account/verify_credentials.json').body
      end

      def access_token(token, secret)
        access_token = ::OAuth::AccessToken.new consumer, token, secret
      end

      def request_token(request_token, request_token_secret)
        OAuth::RequestToken.new(consumer, request_token, request_token_secret)
      end

    end

  end
end

