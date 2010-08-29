# -*- condig: utf-8 -*-
$KCODE = 'u' unless RUBY_VERSION > '1.9'
require 'rubygems'
#require 'nokogiri' #=> ruby1.9.2だとここに書かないと何かロードできないのでとりあえずここに置く後で調べる

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
