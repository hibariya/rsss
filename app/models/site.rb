# -*- condig: utf-8 -*-

class Site
  include Mongoid::Document
  
  field :uri, :type=>String
  field :site_uri, :type=>String
  field :title, :type=>String
  field :updated_at, :type=>Time # entries の最終更新日時

  embeds_many :histories
  embeds_many :entries
  embedded_in :user, :inverse_of=>:sites

  validates :uri, :presence=>true, :length=>{:maximum=>400}, :format=>URI.regexp(['http'])
  validates :site_uri, :length=>{:maximum=>400}, :format=>URI.regexp(['http']), :allow_blank=>true
  validates :title, :length=>{:maximum=>200}
  validate do |site|
    site.errors.add(:uri, 'URI already exists') if site.duplicate?
  end

  def unique?
    (user.sites rescue []).select{|s| s.uri==uri && s.id!=id }.empty?
  end

  def duplicate?
    !unique? end

  def history(num=0)
    histories.sort_by(&:created_at).reverse[num] || History.new end

  def categories
    entries.map(&:categories).flatten end

  #
  # entriesを最新に更新(100件までfetch)
  #
  def reload_channel
    load_channel_info
    self.entries = ((feed.respond_to?(:entries)? feed.entries: feed.items)||[])[0..99].
      map{|e| Rsss::Rss::Entry.extract(e).to_entry }
    self.updated_at = Time.now
    self
  end

  def reload_channel!
    entries.delete_all
    reload_channel.save!
  end

  def load_channel_info
    self.title = (feed.respond_to?(:title)? feed.title.content: feed.channel.title).to_s 
    self.site_uri = feed.respond_to?(:link)? feed.link.href: feed.channel.link
    self
  end

  def load_channel_info!
    load_channel_info.save! end
 
  def feed
    @feed ||= Rsss::Rss.get uri end

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
    param.to_f/day_length(now) 
  rescue ZeroDivisionError
    0.0 end

  #
  # そのフィードが何秒分に相当するか
  # 15日以上のブランクは影響が大きすぎるのでカウントしないでやってみる
  #
  def time_length(now=Time.now)
    now = now.to_i
    blank_limit = 86400*15
    # entry間の秒数を足していく。ただし(15*86400)より長ければ(15*86400)として扱う
    entries.sort_by(&:date).reverse.map{|e| e.date.to_i }.inject([now, 0]) do |cur, time|
      cur ||= [now, 0]
      draft = cur.first-time
      draft = 0 if draft<0 # 現在よりも未来の日付があればひとつめのそれを基準にする
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

end
