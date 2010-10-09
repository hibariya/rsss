# -*- encoding: utf-8 -*-

class User
  include Mongoid::Document
  include Mongoid::Timestamps

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

  embeds_many :sites
  embeds_many :summarized_categories
  embeds_many :summarized_near_users

  index :token, :unique=>true, :background=>true
  index :screen_name, :unique=>true, :background=>true
  index %q(entries.date), :background=>true
  index %q(sites.uri), :background=>true
  
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

  scope :by_token, lambda{|t|
    where(:token=>t)
  }

  scope :by_screen_name, lambda{|s|
    where(:screen_name=>s)
  }

  #
  # ドット(.)の含まれていないすべてのカテゴリをサマる
  # 大文字小文字は区別しない
  #
  def update_summarized_categories!
    self.summarized_categories.delete_all
    self.summarized_categories = Rsss::Summarize.
      segment(categories.inject({}){|r,c| r[c]||=0; r[c]+=1; r}.to_a).
      map{|su| SummarizedCategory.new(:category=>su.first, :level=>su.last) }
    self.save!
  end

  #
  # カテゴリ一覧
  # 大文字小文字は区別しない
  # 出現回数も知りたいのでユニークではない
  #
  def categories
    @categories ||= sites.map(&:categories).flatten.map(&:downcase)
  end

  #
  # 嗜好の近いユーザをn人
  #
  def update_summarized_near_users!(limit=20)
    mycats = self.summarized_categories
    scores = (self.class.any_in(:'summarized_categories.category'=>mycats.map(&:category)).to_a-[self]).
      map do |user|
      mycats.inject([]) do |r, cat|
        if match = user.summarized_categories.select{|ancat| cat.category==ancat.category}.first
          [user.screen_name, r.last.to_i+(match.level+1)*(cat.level+1)]
        else r end
      end
    end
    self.summarized_near_users.delete_all
    self.summarized_near_users = Rsss::Summarize.segment(scores.sort_by(&:last).reverse[0..(limit-1)]).
      map{|su| SummarizedNearUser.new(:screen_name=>su.first,:level=>su.last) }
    self.save!
  end
  
  def recent_entries
    @recent_entries ||= sites.map(&:entries).flatten.sort_by{|e| e.date || e.created_at }.reverse
  end

  def summaries(num=0)
    @summaries ||= sites.map{|s| s.histories.sort_by(&:created_at).reverse[num] }.compact end

  def user_info
    @user_info ||= Rsss::Oauth.user_info(oauth_token, oauth_secret) end

  def reload_user_info!(ignore_user=nil)
    new_screen_name = user_info['screen_name']
    # OAuthでDenyされていたときはnilになるので何もしない(応急処置)
    return false if new_screen_name.nil?
    if new_screen_name != screen_name
      yet_another = self.class.by_screen_name(new_screen_name).first
      yet_another.reload_user_info!(self) if yet_another && yet_another!=ignore_user
      self.screen_name = new_screen_name
    end
    self.oauth_description = user_info['description']
    self.oauth_name = user_info['name']
    self.profile_image_url = user_info['profile_image_url']
    self.save!
  end

  #
  # 過去30日間の遷移を更新。重複した日付のhistoryは削除される
  # siteの最終更新日時が12時間以内の場合はフィードのfetchは行わない
  #
  def create_histories!(now=Time.now)
    self.sites.each do |site|
      if (now.to_i-site.updated_at.to_i)>(3600*12)
        site.reload_channel! rescue next
      end
      todays = site.histories.select{|h| h.created_at.strftime('%Y%m%d')==now.strftime('%Y%m%d')}
      todays.first.delete unless todays.empty?
      (site.histories.sort_by(&:created_at).reverse[29..-1] || []).
        compact.each{|d| d.delete }
    end
    
    Rsss::Summarize.new(self.sites).each do |site, summary|
      site.histories<<History.new(summary.merge({:created_at=>now}))
    end
    self.save!
  end

  #
  # DBの容量を節約(集計以外に必要のないデータを削除)
  # create_histories!が終わった直後に
  #
  def be_skinny!
    now = Time.now
    self.sites.map do |site|
      if site.entries.length>5
        site.entries.sort_by(&:date).reverse[5..-1].
          select{|e| (e.date.to_i+86400) < now.to_i }.
          map(&:delete)
      end
    end
  end
end
