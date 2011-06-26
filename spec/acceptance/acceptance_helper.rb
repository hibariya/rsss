# -*- coding: utf-8 -*-

#require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'spec_helper'

RSpec.configure do |config|
  Capybara.use_default_driver
  config.include Capybara, type: :acceptance

  Capybara.register_driver :selenium do |app|
    Capybara::Driver::Selenium.new(app, browser: :chrome)
  end

  Capybara.default_wait_time = 5

  config.before :all, driver: :selenium do
    Capybara.current_driver = :selenium
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.after :all, driver: :selenium do
    Capybara.use_default_driver
  end

end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

