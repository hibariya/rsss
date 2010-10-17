# -*- encoding: utf-8 -*-
$KCODE = 'u' unless RUBY_VERSION > '1.9'
require 'rubygems'
require 'open-uri'
require 'rss'
require 'kconv'

# Set up gems listed in the Gemfile.
gemfile = File.expand_path('../../Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)
