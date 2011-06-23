Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['RSSS_OAUTH_CONSUMER_KEY'], ENV['RSSS_OAUTH_CONSUMER_SECRET']
end
