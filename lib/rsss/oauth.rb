
module Rsss
  class Oauth
    class << self
      def consumer
        @consumer ||= ::OAuth::Consumer.new(
          Rsss::OAUTH_CONSUER_KEY,
          Rsss::OAUTH_CONSUMER_SECRET,
          {:site=>'http://twitter.com'})
      end

      def user_info(token, secret)
        access_token = ::OAuth::AccessToken.new consumer, token, secret
        ::JSON.parse access_token.get('/account/verify_credentials.json').body
      end
    end

  end
end

