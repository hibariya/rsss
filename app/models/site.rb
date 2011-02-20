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
    self.reload
    self.failed_at = Time.now
    save!(:validate => false)
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
    entries.clear
    feed.entries.map do |entry|
      e = Entry.new :site => self
      e.title      = entry.title
      e.content    = (entry.content || entry.summary).to_s[0..4000] 
      e.categories = (entry.categories || []).uniq.compact.reject(&:empty?)
      e.link       = entry.url
      e.date       = entry.published || entry.updated
      e.save!
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
    @feed ||= Feedzirra::Feed.parse Mechanize.new.get(uri).body
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

  def detectable?
    detects.present?
  end

  def detects
    return @detected_sites if @detected_sites

    @detected_feeds = alternates.map do |alternate|
      site = Site.new(:uri => URI.join(uri, alternate).to_s)
      if site.available?
        site.reload_channel
        site
      end
    end.compact
  end

 private
  def alternates
    return @alternates if @alternates
    agent = Mechanize.new
    agent.get uri
    links = agent.page.root.search('link')
    @alternates = links.select{|l| l.attributes['rel'].to_s=='alternate' }. 
      map{|l| l.attributes['href'].to_s }
  rescue
    []
  end

  def strip_tags_and_spaces(s)
    s.gsub(/<\/?[^>]+>|\s/, '')
  end
end
