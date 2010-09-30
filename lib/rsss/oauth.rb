
module Rsss
  class Oauth
    class << self
      def consumer
        @consumer ||= ::OAuth::Consumer.new(
          Rsss::OAUTH_CONSUER_KEY,
          Rsss::OAUTH_CONSUMER_SECRET,
          {:site=>'https://twitter.com'})
      end

      def user_info(token, secret)
        access_token = ::OAuth::AccessToken.new consumer, token, secret
        ::JSON.parse access_token.get('/account/verify_credentials.json').body
      end

      def request_token(request_token, request_token_secret)
        OAuth::RequestToken.new(consumer, request_token, request_token_secret)
      end

    end

  end
end

