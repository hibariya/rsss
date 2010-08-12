class User
  include Mongoid::Document

  field :screen_name, :type=>String
  #field :name, :type=>String
  #field :description, :type=>String
  #field :site, :type=>String

  field :created_at, :type=>Time
  field :updated_at, :type=>Time

  field :oauth_token, :type=>String
  field :oauth_secret, :type=>String
  field :token, :type=>String

  embeds_many :sites
  attr_accessor :feeds, :summaries

  def self.find_by_token(t)
    find(:first, :conditions=>{:token=>t})
  end

  def summaries
    histories_at 0 end

  def histories_at(num)
    sites.map{|s| s.histories.sort_by{|h| h.created_at }.reverse[num] }.find_all{|s| !s.nil?} end

  #
  # 過去30日間の遷移を更新
  #
  def create_histories
    now = Time.now
    sites.each{|s| s.recent_entries.delete_all } 
    save
    reload
    if sites.length==1
      site = sites.last
      site.reload_channel
      site.entries.each do |entry|
          site.recent_entries<<RecentEntry.new(:title=>entry.title, :content=>entry.snipet,
                                               :link=>entry.link, :date=>entry.date)
      end
      site.histories<<History.new(:volume_level=>24, :frequency_level=>24, :created_at=>now)
    
    else
      feeds.each do |feed|
        site = sites.select{|s| s.uri==feed.uri }.first
        site.reload_channel
        site.entries.each do |entry|
          site.recent_entries<<RecentEntry.new(:title=>entry.title, :content=>entry.snipet,
                                               :link=>entry.link, :date=>entry.date)
        end

        todays = site.histories.select{|h| h.created_at.strftime('%Y%m%d%H')==now.strftime('%Y%m%d%H')}.first
        todays.delete unless todays.nil?
        site.histories<<History.new(:volume_level=>feed.volume_level, 
                                    :frequency_level=>feed.frequency_level, :created_at=>now)
        (site.histories.sort_by{|h| h.created_at }.reverse[32..-1] || []).
          each{|d| d.delete unless d.nil?} if site.histories.length > 31
      end
    end

    save && self
  end

  def feeds
    @feeds ||= Feeds.new(sites.map{|f| f.entries rescue nil }.find_all{|s|!s.nil?}) end

  #
  # フィードの一覧を相対評価するための何か
  #
  class Feeds
    attr_accessor :feeds

    def initialize(feeds=[])
      raise ArgumentError unless feeds.kind_of? Array
      @feeds = feeds
      segment_by_volume
      segment_by_frequency
    end

    def method_missing(name, *args, &block)
      @feeds.__send__ name, *args, &block end

    #
    # POST量をみて評価
    #
    def segment_by_volume
      segment(@feeds.map{|f| [f, f.volume] }).map do |site|
        site.first.volume_level = site.last
        site
      end
    end

    #
    # POST数をみて評価
    #
    def segment_by_frequency
      segment(@feeds.map{|f| [f, f.frequency] }).map do |site|
        site.first.frequency_level = site.last
        site
      end
    end

    #
    # 24点満点の相対評価を行う
    #
    def segment(levels, step=24)
      max = Math.sqrt levels.inject(0){|r,c| (c.last > r)? c.last: r}
      min = Math.sqrt levels.inject(max){|r,c| (c.last < r)? c.last: r}
      factor = step/(max-min)
      levels.map{|l| [l.first, ((Math.sqrt(l.last)-min)*factor).round] }
    end
  end

end
