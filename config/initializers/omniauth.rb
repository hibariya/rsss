module Rsss
  OAUTH_CONSUMER_KEY    = ENV['RSSS_OAUTH_CONSUMER_KEY']
  OAUTH_CONSUMER_SECRET = ENV['RSSS_OAUTH_CONSUMER_SECRET']
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, Rsss::OAUTH_CONSUMER_KEY, Rsss::OAUTH_CONSUMER_SECRET
end

