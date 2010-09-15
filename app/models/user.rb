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

  def summaries(num=0)
    sites.map{|s| s.histories.sort_by(&:created_at).reverse[num] }.compact end

  def reload_screen_name

  end

  #
  # 過去30日間の遷移を更新。重複した日付のhistoryは削除される
  #
  def create_histories(now=Time.now)
    self.sites.each do |site|
      site.reload_channel rescue next
      todays = site.histories.select{|h| h.created_at.strftime('%Y%m%d')==now.strftime('%Y%m%d')}
      todays.first.delete unless todays.empty?
      (site.histories.sort_by(&:created_at).reverse[30..-1] || []).
        compact.each{|d| d.delete }
    end
    
    Rsss::Summarize.new(self.sites).each do |site, summary|
      site.histories<<History.new(summary.merge({:created_at=>now}))
    end
    self.save
  end

end
