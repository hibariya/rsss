# -*- condig: utf-8 -*-
require 'machinist'
require 'mongoid'
require 'machinist/mongoid'
require 'mongoid-rspec'

Sham.define do
  screen_name { Faker::Internet.user_name }
  description { Faker::Lorem.paragraph }
  site { ['http://', Faker::Internet.domain_name].join }
  oauth_user_id {|i| 1000+i }
  token {|i| (Digest::SHA1.new<<i.to_s).to_s }

  title { Faker::Lorem.sentence }
  fixnum25(:unique => false){ rand(24) }
  time {|i| Time.now-i }
end

User.blueprint do
  screen_name 
  description 
  site 
  created_at { Time.now }
  updated_at { Time.now }
  oauth_user_id
  oauth_token Sham.token 
  oauth_secret Sham.token
  token 
  sites { (0..rand(10)).to_a.map{|i| Site.make } }
end

User.blueprint(:after_oauth) do
  created_at { Time.now }
  updated_at { Time.now }
  oauth_user_id
  oauth_token Sham.token 
  oauth_secret Sham.token
  token 
end

Site.blueprint do
  uri Sham.site
  site_uri Sham.site
  title
  histories { (0..30).to_a.map{|i| History.make } }
  recent_entries { (0..30).to_a.map{|i| RecentEntry.make } } 
end

History.blueprint do
  volume_level Sham.fixnum25
  frequency_level Sham.fixnum25
  created_at { Time.now }
end

RecentEntry.blueprint do
  title
  content Sham.description
  link Sham.site
  date Sham.time
end

5.times{ User.make }

