require 'spork'
require 'email_spec'

Spork.prefork do
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] = 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    include OscrFixtureSupport
    config.mock_with :rr

    config.filter_run focus: true
    config.run_all_when_everything_filtered = true

    config.before(:all, clear: :all){ clear_db }
    config.after(:each, clear: :each){ clear_db }

    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
  end
end

Spork.each_run do
  require "#{File.dirname(__FILE__)}/fabricators"
end

