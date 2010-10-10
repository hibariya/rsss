# -*- condig: utf-8 -*-

Fabricator(:authorized_user, :class_name=>:user) do
  screen_name { Fabricate.sequence(:screen_name){|i| [Faker::Internet.user_name, i.to_s].join } }
  created_at { Time.now }
  updated_at { Time.now }
  oauth_user_id { Fabricate.sequence :user_id, 1000 }
  oauth_token { Fabricate.sequence(:token){|i| (Digest::SHA1.new<<i.to_s).to_s } }
  oauth_secret { Fabricate.sequence(:token){|i| (Digest::SHA1.new<<i.to_s).to_s } }
  token { Fabricate.sequence(:token){|i| (Digest::SHA1.new<<i.to_s).to_s } }
end

Fabricator(:user, :from=>:authorized_user) do
  description { Faker::Lorem.paragraph[0..190] }
  site { Fabricate.sequence(:uri){|i| ['http://', i.to_s, Faker::Internet.domain_name].join } }
  sites { (0..rand(10)).to_a.map{|i| Fabricate.build(:site) } }
end

Fabricator(:site) do
  uri { Fabricate.sequence(:uri){|i| ['http://', i.to_s, Faker::Internet.domain_name].join } }
  site_uri { Fabricate.sequence(:uri){|i| ['http://', i.to_s, Faker::Internet.domain_name, '/feed'].join } }
  title { Faker::Lorem.sentence[0..50] }
  histories {(0..30).to_a.map{|i| Fabricate.build(:history) }}
  entries {(0..30).to_a.map{|i| Fabricate.build(:entry) }}
end

Fabricator(:history) do
  volume_level { rand(24) }
  frequency_level { rand(24) }
  created_at { Time.now }
end

Fabricator(:entry) do
  title { Faker::Lorem.sentence[0..50] }
  content { Faker::Lorem.paragraph }
  link { Fabricate.sequence(:uri){|i| ['http://', Faker::Internet.domain_name, '/entry/', i.to_s].join } }
  date { Fabricate.sequence(:time){|t| t.day.ago.to_time } }
end

#5.times{ User.make }

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
                category.content = ::Faker::Internet.user_name
                category.term = ::Faker::Internet.user_name
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

