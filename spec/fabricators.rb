# -*- condig: utf-8 -*-

Sham.define do
  screen_name { Faker::Internet.user_name }
  description { Faker::Lorem.paragraph[0..190] }
  uri {|i| ['http://', i.to_s, Faker::Internet.domain_name].join }
  user_id {|i| 1000+i }
  token {|i| (Digest::SHA1.new<<i.to_s).to_s }
  title { Faker::Lorem.sentence[0..50] }
  level(:unique=>false){ rand(24) }
  time {|t| t.day.ago.to_time }
end

Fabricator(:authorized_user, :class_name=>:user) do
  screen_name { Sham.screen_name }
  created_at { Time.now }
  updated_at { Time.now }
  oauth_user_id { Sham.user_id }
  oauth_token { Sham.token }
  oauth_secret { Sham.token }
  token { Sham.token }
end

Fabricator(:user, :from=>:authorized_user) do
  description { Sham.description }
  site { Sham.uri }
  sites { (0..rand(10)).to_a.map{|i| Fabricate.build(:site) } }
end

Fabricator(:site) do
  uri { Sham.uri }
  site_uri { Sham.uri }
  title { Sham.title }
  histories {(0..30).to_a.map{|i| Fabricate.build(:history) }}
  entries {(0..30).to_a.map{|i| Fabricate.build(:entry) }}
end

Fabricator(:history) do
  volume_level { Sham.level }
  frequency_level { Sham.level }
  created_at { Time.now }
end

Fabricator(:entry) do
  title { Sham.title }
  content { Sham.description }
  link { Sham.uri }
  date { Sham.time }
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

class << Rsss::Rss #{{{ rss1.0 2.0 atom のサンプルを生成するテスト用メソッド
  def sample_feed(version)
    begin
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
            e = Fabricate.build(:entry)
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

