# -*- condig: utf-8 -*-

class Site
  include Mongoid::Document
  
  field :uri, :type=>String
  field :site_uri, :type=>String
  field :title, :type=>String
  embeds_many :histories
  embeds_many :entries
  embedded_in :user, :inverse_of=>:sites

  validates :uri, :presence=>true, :length=>{:maximum=>400}, :format=>URI.regexp
  validates :site_uri, :length=>{:maximum=>400}, :format=>URI.regexp, :allow_blank=>true
  validates :title, :length=>{:maximum=>200}
  validate do |site|
    site.errors.add(:uri, 'URI already exists') if site.duplicate?
  end

  def unique?
    (user.sites rescue []).select{|s| s.uri==uri && s.id!=id }.empty?
  end

  def duplicate?
    !unique? end

  def history_at(num=0)
    histories.sort_by{|h| h.created_at }.reverse[num] || History.new end

  #
  # entriesを最新に更新
  #
  def reload_channel
    load_channel_info
    entries.delete_all
    self.entries = (feed.respond_to?(:entries)? feed.entries: feed.items).
      map{|e| EntryExtractor.new(e).to_entry }
    self
  end

  def reload_channel!
    reload_channel.save && self end

  def load_channel_info
    self.title = (feed.respond_to?(:title)? feed.title.content: feed.channel.title).to_s 
    self.site_uri = feed.respond_to?(:link)? feed.link.href: feed.channel.link
    self
  end

  def load_channel_info!
    load_channel_info.save && self end
 
  def feed
    return @feed if @feed
    u = URI.parse(uri)
    u.query = (u.query.nil?? '' : u.query+'&')+Time.now.to_i.to_s 
    @feed = u.open{|f| RSS::Parser.parse(f.read, false, true) }
  end

  #
  # サイトの1日当たりのPOST量(byte)
  #
  def volume
    count_daily byte_length end

  #
  # サイトの1日当たりのPOST数
  #
  def frequency
    count_daily length end

  #
  # 全体の量を日数で割って1日あたりどれくらいかなんとなく出す
  #
  def count_daily(param, now=Time.now)
    param.to_f/day_length(now) end

  #
  # そのフィードが何秒分に相当するか
  # 15日以上のブランクは影響が大きすぎるのでカウントしないでやってみる
  #
  def time_length(now=Time.now)
    now = now.to_i
    blank_limit = 86400*15
    # entry間の秒数を足していく。ただし(15*86400)より長ければ(15*86400)として扱う
    entries.sort_by{|e| e.date }.reverse.map{|e| e.date.to_i }.inject([now, 0]) do |cur, time|
      cur ||= [now, 0]
      draft = cur.first-time
      [time, cur.last+((draft > blank_limit)? blank_limit: draft)]
    end.last
  end

  #
  # そのフィードが何日分に相当するか
  #
  def day_length(now=Time.now)
    time_length(now).to_f/86400 end

  #
  # フィード内の全ての記事のタイトルと本文のバイト数をざっくりと
  #
  def byte_length
    entries.map{|e| [e.title, e.content] }.flatten.join.length
  end

  def length
    entries.length end

  #
  # フィードの中で一番昔の日付
  #
  def earliest_date
    entries.inject(nil){|r,c| r||=c.date; (r>c.date)? c.date: r } end

  #
  # フィードの中で最新の日付
  #
  def latest_date
    @entries.inject(nil){|r,c| r||=c.date; (r<c.date)? c.date: r } end

  #
  # フィード中の1エントリーに相当する部分
  #
  class EntryExtractor
    attr_reader :entry

    def initialize(entry)
      raise ArgumentError unless [RSS::RDF::Item, RSS::Atom::Feed::Entry, RSS::Rss::Channel::Item].
        any?{|c| entry.kind_of? c }
      @entry = entry
    end

    #
    # Entryインスタンスとして返す
    #
    def to_entry
      Entry.new([:title, :content, :link, :categories, :date].
        inject({}){|r,a|r.merge({a.intern=>self.send(a)})})
    end

    #
    # エントリのタイトルに相当しそうな部分を取得
    #
    def title
      @title ||= [:title].inject(nil) do |res, m|
        if @entry.respond_to?(m)  && !@entry.__send__(m).nil? && res.nil?
          res = @entry.__send__ m 
          res.respond_to?(:content)? res.content: res
        else res end
      end or ''
    end
    
    #
    # エントリのコンテンツ本体に相当しそうな部分
    #
    def content
      @content ||= [:content_encoded, :content, :description, :summary, :subtitle].inject(nil) do |res, m|
        if @entry.respond_to?(m)  && !@entry.__send__(m).nil? && res.nil?
          res = @entry.__send__ m 
          res.respond_to?(:content)? res.content: res
        else res end
      end or ''
    end

    def snipet(len=120)
      content.gsub(/<[^>]+>/, '').gsub(/[\n\r\s]/, '').scan(/./)[0...len].join
    end

    #
    # エントリのURIに相当しそうな部分
    #
    def link
      @link ||= [:about, :link].inject(nil) do |res, m|
        if @entry.respond_to?(m)  && !@entry.__send__(m).nil? && res.nil?
          res = @entry.__send__ m 
          res.respond_to?(:href)? res.href: res
        else res end
      end
    end

    #
    # カテゴリ的なもの
    #
    def categories
      @categories ||= [:categories, :dc_subjects, :dc_categories].inject([]) do |res, m|
        if @entry.respond_to?(m)  && !@entry.__send__(m).nil?
          (res+@entry.__send__(m).map{|c| (c.respond_to?(:content)? c.content: c) or '' }).uniq
        else res end
      end or []
    end

    #
    # 日付っぽいもの
    #
    def date
      @date ||= [:published, :pubDate, :date, :updated, :dc_date].inject(nil) do |res, m|
        if @entry.respond_to?(m)  && !@entry.__send__(m).nil? && res.nil?
          res = @entry.__send__ m 
          res.respond_to?(:content)? res.content: res
        else res end
      end
    end
  end

end
