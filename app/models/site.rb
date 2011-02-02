# -*- encoding: utf-8 -*-

class Site
  include Mongoid::Document
  include Mongoid::Timestamps

  require 'feedzirra'
  
  field :uri,       :type => String
  field :site_uri,  :type => String
  field :title,     :type => String
  field :failed_at, :type => Time

  embeds_many :entries
  referenced_in :user

  validates :uri,
    :presence => true,
    :length => {:maximum => 400},
    :format => URI.regexp(%w[http https]),
    :uniqueness => {:scope => :user_id}
  validates :site_uri,
    :length => {:maximum => 400},
    :format => URI.regexp(%w[http https]),
    :uniqueness => {:scope => :user_id},
    :allow_blank => true
  validates :title,
    :length => {:maximum=>200}

  # failed_at を更新
  def failed!
    self.failed_at = Time.now
    save!
  end

  def reload_and_save
    reload_channel
    reload_entries
    save!
  rescue
    failed!
    raise $!
  end

  # フィードを取得しサイトのタイトルとURIを更新
  def reload_channel
    self.title, self.site_uri = feed.title, feed.url
  end

  # フィードを取得しEntriesを更新
  def reload_entries
    self.entries = feed.entries.map do |entry|
      Entry.new :title      => entry.title,
                :content    => entry.summary,
                :categories => (entry.categories || []),
                :link       => entry.url,
                :date       => entry.published,
                :site       => self
    end
  end

  # フィードからタイトル/最新のエントリが取得できるか否か
  def available?
    [feed.title, feed.entries.first].all?
  rescue
    false
  end

  def unavailable?; !available? end

  # フィードをメモ
  def feed
    @feed ||= open(uri){|p| Feedzirra::Feed.parse p.read }
  end

  def categories
    @categories ||= entries.map(&:categories).flatten
  end

  # 1日あたりの更新頻度
  def frequency
    entries.length.to_f / day_length
  end

  # 1日あたりの更新バイト数
  def volume
    all_content = entries.map{|e| "#{e.title}#{e.content}" }.join
    all_content_length = strip_tags_and_spaces(all_content).length
    all_content_length.to_f / day_length
  end

  # 最初のフィードと最後のフィードの間の日数
  def day_length; time_length / 86400.0 end

  # 最初のフィードと最後のフィードの間の秒数
  def time_length
    sorted_entries = entries.map(&:date).sort
    diffs = Time.now.to_i - sorted_entries.min.to_i
    raise RSSInvalidDateError if diffs < 0
    diffs.to_f
  end

  def clean_histories(offset=30)
    histories.sort_by(&:created_at)[offset..-1].map(&:delete)
  end

  def to_feed(version='1.0')
    RSS::Maker.make version do |maker|
      maker.channel.title  = maker.channel.description = title
      maker.channel.about  = uri
      maker.channel.link   = site_uri
      maker.channel.date   = Time.now #
      maker.channel.author = user.screen_name
      maker.items.do_sort  = true

      entries.each do |entry|
        maker.items.new_item do |item|
          %w(link title date description).each do |attr|
            item.send "#{attr}=", entry.send(attr)
          end
          entry.categories.each do |category_name|
            item.categories.new_category{|c| c.content = c.term = category_name }
          end
        end
      end
    end
  end

  private
  def strip_tags_and_spaces(s)
    s.gsub(/<\/?[^>]+>|\s/, '')
  end
end
