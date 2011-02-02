class UserPresenter
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def sites_by_score
    sites.sort_by{|site| site.summary.score }.reverse
  end

  def recent_entries(limit=-1)
    entries.sort_by(&:date).reverse[0...limit]
  end

  def categories_by_frequency(limit=-1)
    categories.sort_by(&:frequency).reverse[0..limit]
  end

  def associates_by_score(limit=-1)
    associates.sort_by(&:score).reverse[0..limit]
  end

  def entries
    sites.map(&:entries).flatten
  end

  def categories
    @user.categories.map{|c| CategoryPresenter.new c }
  end

  def associates
    @user.associates.map{|a| AssociatePresenter.new a }
  end

  def sites
    @user.sites.map{|s| SitePresenter.new s }
  end

  def method_missing(name, *args)
    @user.send name, *args rescue @user.auth_profile.send name, *args
  end

  class << self
    def load_by_screen_name(screen_name)
      new by_screen_name(screen_name).first
    end

    alias load load_by_screen_name

    def method_missing(name, *args)
      User.send name, *args
    end
  end
end
