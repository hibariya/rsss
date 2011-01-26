require 'rubygems'

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'mongoid'
require 'mongoid-rspec'
require 'fabrication'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
require "#{File.dirname(__FILE__)}/fabricators"

RSpec.configure do |config|
  config.mock_with :rr

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  
  config.before :all, :clear=>true do
    Mongoid.master.collections.select { |c| c.name != 'system.indexes' }.each(&:drop) rescue nil
  end
end

