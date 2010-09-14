# -*- condig: utf-8 -*-

class User
  include Mongoid::Document

  field :screen_name, :type=>String
  field :description, :type=>String
  field :site, :type=>String
  field :oauth_user_id, :type=>String
  field :oauth_token, :type=>String
  field :oauth_secret, :type=>String
  field :token, :type=>String
  field :created_at, :type=>Time
  field :updated_at, :type=>Time

  embeds_many :sites

  validates :screen_name, :presence=>true, :length=>{:maximum=>60}, :format=>/^[a-zA-Z0-9_\.]*$/
  validates :description, :length=>{:maximum=>200}
  validates :site, :length=>{:maximum=>400}, :format=>URI.regexp(['http']), :allow_blank=>true
  validates :oauth_user_id, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9]+$/
  validates :oauth_token, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9a-zA-Z\-]+$/
  validates :oauth_secret, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9a-zA-Z]+$/
  validates :token, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9a-zA-Z]+$/

  attr_accessor :feeds, :summaries

  validate do |user|
    user.errors.add(:description, 'too long Description') if user.description.to_s.length > 500
    user.errors.add(:site, 'too long URI') if user.site.to_s.length > 100
  end

  def self.find_by_token(t)
    find(:first, :conditions=>{:token=>t}) end

  def summaries
    histories_at 0 end

  def histories_at(num)
    sites.map{|s| s.histories.sort_by{|h| h.created_at }.reverse[num] }.compact end

  #
  # 過去30日間の遷移を更新。重複した日付のhistoryは削除される
  #
  def create_histories
    self.sites.each do |site|
      site.reload_channel rescue next
      todays = site.histories.select{|h| h.created_at.strftime('%Y%m%d')==now.strftime('%Y%m%d')}
      todays.first.delete unless todays.empty?
      (site.histories.sort_by{|h| h.created_at }.reverse[30..-1] || []).
        compact.each{|d| d.delete }
    end
    SnapShot.take(self).save
  end

  class SnapShot
    class << self
      #
      # 渡されたuserのsites[i].entries から各サイトの更新度を抽出して相対評価してsites[i].historiesに保存
      #
      def take(user)
        now = Time.now
        self.new(user.sites).each do |site, snapshot|
          site.histories<<History.new(snapshot.merge({:created_at=>now}))
        end
        user
      end

      #
      # 24点満点の相対評価を行う
      #
      def segment(levels, step=24)
        return levels.map{|l| [l.first, l.last.to_i] } if levels.all?{|l| l.last.to_f==0.0 }
        max = Math.sqrt levels.inject(0){|r,c| (c.last > r)? c.last: r}
        min = Math.sqrt levels.inject(max){|r,c| (c.last < r)? c.last: r}
        factor = step/(max-min)
        levels.map{|l| [l.first, ((Math.sqrt(l.last)-min)*factor).round] }
      end
    end

    def initialize(sites=[])
      raise ArgumentError unless sites.kind_of? Array
      @sites, @snapshot = sites, {}
      segment_by_volume
      segment_by_frequency
    end

    #
    # POST量をみて評価
    #
    def segment_by_volume
      segment(@sites.map{|f| [f, f.volume] }).map do |site|
        @snapshot[site.first] ||= {}
        @snapshot[site.first][:volume_level] = site.last
      end
    end

    #
    # POST数をみて評価
    #
    def segment_by_frequency
      segment(@sites.map{|f| [f, f.frequency] }).map do |site|
        @snapshot[site.first] ||= {}
        @snapshot[site.first][:frequency_level] = site.last
      end
    end

    def segment(levels, step=24)
      self.class.segment(levels, step) end

    def method_missing(name, *args, &block)
      @snapshot.__send__ name, *args, &block end 
  end

end
