class UserPresenter
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def sites_by_score
    @sites_by_score ||= sites.sort_by{|site| site.summary.score }.reverse
  end

  def recent_entries(limit=-1)
    entries.sort_by(&:date).reverse[0...limit]
  end

  def categories_by_frequency(limit=-1)
    categories.sort_by(&:frequency).reverse[0..limit].sort_by(&:name)
  end

  def associates_by_score(limit=-1)
    associates.sort_by(&:score).reverse[0..limit]
  end

  def entries
    @entries ||= sites.map(&:entries).flatten.sort_by(&:date).reverse
  end

  def categories
    @categories ||= @user.categories.map{|c| CategoryPresenter.new c, @user }
  end

  def associates
    @associates ||= @user.associates.map{|a| AssociatePresenter.new a, @user }
  end

  def sites
    @sites ||= @user.sites.map{|s| SitePresenter.new s, @user }.select(&:summaries?)
  end

  def sites?
    !sites.empty?
  end

  def has_profile?
    @user.site? || @user.description?
  end

  def categories?
    !categories.empty?
  end

  def associates?
    !associates.empty?
  end

  # TODO: remove 
  def method_missing(name, *args)
    @user.respond_to?(name)?
      @user.send(name, *args):
      @user.auth_profile.send(name, *args)
  end

  class << self
    def load_by_screen_name(screen_name)
      new User.by_screen_name(screen_name).first
    end

    alias load load_by_screen_name
  end
end
