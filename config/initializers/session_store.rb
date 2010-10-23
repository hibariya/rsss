# Be sure to restart your server when you modify this file.

Rsss::Application.config.session_store :cookie_store, 
  :key => '_rsss_session',
  :expire_after=>86400*60

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Rsss::Application.config.session_store :active_record_store
