# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/../spec_helper"
require "steak"
require 'capybara/rails'

RSpec.configure do |config|
  config.include Capybara, :type => :acceptance
  Capybara.default_selector = :css
end


