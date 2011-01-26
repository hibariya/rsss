# -*- coding: utf-8 -*-

Fabricator(:authorized_user, :class_name=>:user) do
  created_at   { Time.now }
  updated_at   { Time.now }
  token        { Fabricate.sequence(:token){|i| (Digest::SHA1.new<<i.to_s).to_s } }
  auth_profile { Fabricate.build :auth_profile }
end

Fabricator(:auth_profile) do
  screen_name       { Fabricate.sequence(:screen_name){|i| Faker::Internet.user_name + i.to_s } }
  user_id           { Fabricate.sequence :user_id, 1000 }
  token             { Fabricate.sequence(:token){|i| (Digest::SHA1.new<<i.to_s).to_s } }
  secret            { Fabricate.sequence(:token){|i| (Digest::SHA1.new<<i.to_s).to_s } }
  description       { Faker::Lorem.paragraph[0..190] }
  name              { 'fabricate' }
  profile_image_url { Fabricate.sequence(:uri){|i| "http://#{i}#{Faker::Internet.domain_name}" } }
end

Fabricator(:user, :from=>:authorized_user) do
  description { Faker::Lorem.paragraph[0..190] }
  site        { Fabricate.sequence(:uri){|i| "http://#{i}#{Faker::Internet.domain_name}" } }
  sites       { 5.times.map{|t| Fabricate :site } }
end

Fabricator(:example_user, :from=>:authorized_user) do
  description { Faker::Lorem.paragraph[0..190] }
  site        { Fabricate.sequence(:uri){|i| "http://#{i}#{Faker::Internet.domain_name}" } }
  sites       { [Fabricate.build(:example_site)] }
end

Fabricator(:site) do
  uri      { Fabricate.sequence(:uri){|i| "http://#{i}#{Faker::Internet.domain_name}" } }
  site_uri { Fabricate.sequence(:uri){|i| "http://#{i}#{Faker::Internet.domain_name}/feed" } }
  title    { Faker::Lorem.sentence[0..50] }
  entries  { 30.times.map{|i| Fabricate.build(:entry) } }
end

Fabricator(:example_site, :class_name=>:site) do
  title     { 'site for stub' }
  uri       { 'http://example.com/feed' }
  site_uri  { 'http://example.com/' }
  failed_at { nil }
  entries   { [Fabricate.build(:example_entry)] }
end

Fabricator(:entry) do
  title      { Faker::Lorem.sentence[0..50] }
  content    { Faker::Lorem.paragraph }
  link_uri   { Fabricate.sequence(:uri){|i| "http://#{Faker::Internet.domain_name}/entry/#{i}" } }
  date       { Fabricate.sequence(:time){|t| t.day.ago.to_time } }
  categories { Faker::Lorem.paragraph.split.sort{ rand }[0..3] }
end

Fabricator(:example_entry, :class_name=>:entry) do
  title      { 'entry for stub' }
  content    { 'content for stub' }
  categories { %w(category for stub) }
  link_uri   { 'http://example.com/entries/stub' }
  date       { 1.day.ago.to_time }
end

