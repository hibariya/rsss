# -*- condig: utf-8 -*-

class User
  include Mongoid::Document

  field :screen_name, :type=>String

  field :oauth_user_id, :type=>String
  field :oauth_token, :type=>String
  field :oauth_secret, :type=>String
  field :oauth_description, :type=>String
  field :oauth_name, :type=>String
  field :profile_image_url, :type=>String
  
  field :description, :type=>String
  field :site, :type=>String
  field :token, :type=>String
  field :created_at, :type=>Time

  embeds_many :sites

  validates :screen_name, :presence=>true, :length=>{:maximum=>60}, :format=>/^[a-zA-Z0-9_\.]*$/
  validates :oauth_user_id, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9]+$/
  validates :oauth_token, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9a-zA-Z\-]+$/
  validates :oauth_secret, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9a-zA-Z]+$/
  validates :oauth_description, :length=>{:maximum=>400}
  validates :oauth_name, :length=>{:maximum=>60}
  validates :profile_image_url, :length=>{:maximum=>400}, :format=>URI.regexp(['http']), :allow_blank=>true
  
  validates :token, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9a-zA-Z]+$/
  validates :description, :length=>{:maximum=>200}
  validates :site, :length=>{:maximum=>400}, :format=>URI.regexp(['http']), :allow_blank=>true

  validate do |user|
    user.errors.add(:description, 'too long Description') if user.description.to_s.length > 500
    user.errors.add(:site, 'too long URI') if user.site.to_s.length > 100
  end

  def self.find_by_token(t)
    find(:first, :conditions=>{:token=>t}) end

  def summaries(num=0)
    sites.map{|s| s.histories.sort_by(&:created_at).reverse[num] }.compact end

  def user_info
    @user_info ||= Rsss::Oauth.user_info(oauth_token, oauth_secret) end

  def reload_user_info!(ignore_user=nil)
    new_screen_name = user_info['screen_name']
    if new_screen_name != screen_name
      yet_another = self.class.find(:first, :conditions=>{:screen_name=>new_screen_name})
      yet_another.reload_user_info!(self) if yet_another && yet_another!=ignore_user
      self.screen_name = new_screen_name
    end
    self.oauth_description = user_info['description']
    self.oauth_name = user_info['name']
    self.profile_image_url = user_info['profile_image_url']
    self.save
  end

  #
  # 過去30日間の遷移を更新。重複した日付のhistoryは削除される
  #
  def create_histories!(now=Time.now)
    self.sites.each do |site|
      site.reload_channel rescue next
      todays = site.histories.select{|h| h.created_at.strftime('%Y%m%d')==now.strftime('%Y%m%d')}
      todays.first.delete unless todays.empty?
      (site.histories.sort_by(&:created_at).reverse[29..-1] || []).
        compact.each{|d| d.delete }
    end
    
    Rsss::Summarize.new(self.sites).each do |site, summary|
      site.histories<<History.new(summary.merge({:created_at=>now}))
    end
    self.save
  end

end
