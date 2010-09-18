# -*- condig: utf-8 -*-

Sham.define do
  screen_name { Faker::Internet.user_name }
  description { Faker::Lorem.paragraph[0..190] }
  site { ['http://', rand(1000).to_s, Faker::Internet.domain_name].join }
  oauth_user_id {|i| 1000+i }
  token {|i| (Digest::SHA1.new<<i.to_s).to_s }

  title { Faker::Lorem.sentence[0..50] }
  fixnum25(:unique=>false){ rand(24) }
  time {|t| t.day.ago.to_time }
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
  entries { (0..30).to_a.map{|i| Entry.make } } 
end

History.blueprint do
  volume_level Sham.fixnum25
  frequency_level Sham.fixnum25
  created_at { Time.now }
end

Entry.blueprint do
  title
  content Sham.description
  link Sham.site
  date Sham.time
end

#5.times{ User.make }

class << Rsss::Rss #{{{ rss1.0 2.0 atom のサンプルを生成するテスト用メソッド
  def sample_feed(version)
    begin
      # avoid NoMethodError: undefined method `make' for nil:NilClass
      raise unless ::RSS::Maker::MAKERS.include?(version)
      rss = ::RSS::Maker.make(version) do |maker|
        maker.channel.about = "http://example.com/index.rss"
        maker.channel.title = "Example"
        maker.channel.description = "Example Site"
        maker.channel.link = "http://example.com/"
        maker.channel.author = "Bob"
        maker.channel.date = Time.now
        maker.items.do_sort = true

        20.times do |t|
          maker.items.new_item do |item|
            e = ::Entry.make_unsaved
            item.link = e.link
            item.title = e.title
            item.date = e.date
            item.description = e.content
            item.categories.new_category do |category|
              3.times.map do |c|
                category.content = ::Sham.screen_name
                category.term = ::Sham.screen_name
              end
            end
          end
        end
      end
      rss.to_s
    rescue
      STDERR.puts "#{version}: #{$!}"
    end
  end
end
#}}}
#puts Site::EntryExtractor.sample_feed('atom')

