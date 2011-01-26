# -*- encoding: utf-8 -*-

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rsss::Analyzable

  field :description, :type=>String
  field :site, :type=>String
  field :token, :type=>String

  embeds_one :auth_profile
  def screen_name; auth_profile.screen_name end
  def screen_name=(name); auth_profile.screen_name = name end

  references_many :sites
  embeds_many :site_summaries

  references_many :categories
  embeds_many :category_summaries

  references_many :associates
  embeds_many :associate_summaries

  index :token, :unique=>true, :background=>true
  index %q(entries.date), :background=>true
  index %q(sites.uri), :background=>true

  validates :token, :presence=>true, :length=>{:within=>1..100}, :format=>/^[0-9a-zA-Z]+$/
  validates :description, :length=>{:maximum=>200}
  validates :site, :length=>{:maximum=>400}, :format=>URI.regexp(['http']), :allow_blank=>true

  validate do
    self.errors.add :auth_profile, 'invalid auth profile' if auth_profile && auth_profile.invalid?
  end

  scope :by_screen_name do |screen_name|
    User.where(:'auth_profile.screen_name' => screen_name)
  end

  def reload_profile; auth_profile.reload_and_save_profile end

  def reload_sites
    sites.each &:reload_and_save
  end

  def reload_site_summaries
    volume_scores    = analyze_by :sites, :volume
    frequency_scores = analyze_by :sites, :frequency
    (volume_scores.zip frequency_scores).map(&:flatten).each do |site, volume, _, frequency|
      self.site_summaries<< SiteSummary.new(:user            => self,
                                            :site_id         => site.id,
                                            :volume_score    => volume,
                                            :frequency_score => frequency)
    end
    save!
  end

  def reload_categories
    cats = sites.map{|site| site.entries.map &:categories }.flatten
    cats.uniq.each do |cat_name|
      cat = categories.where(:name=>cat_name).first 
      cat ||= Category.new(:user=>self, :name=>cat_name)
      cat.frequency = cats.select{|c| c == cat_name }.length
      cat.save
    end
  end

  def reload_category_summaries
    category_scores = analyze_by :categories, :frequency
    category_scores.each do |category, score|
      self.category_summaries<< CategorySummary.create(:user=>self,
                                                       :category_id=>category.id,
                                                       :frequency_score=>score)
    end
    save
  end

  def reload_associates
    (User.all.to_a-[self]).each do |user|
      asc   = associates.where(:associate_user_id => user.id).first 
      asc ||= Associate.new(:user => self, :associate_user_id => user.id)
      asc.score = (user.categories.to_a & categories.to_a).length
      asc.save
    end
    self
  end

  def reload_associate_summaries
    associate_scores = analyze_by :associates, :score
    associate_scores.each do |associate, score|
      self.associate_summaries<< AssociateSummary.create(:user=>self,
                                                         :associate_id=>associate.id,
                                                         :score=>score)
    end
    save
  end

end
