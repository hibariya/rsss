class SitePresenter
  attr_accessor :site

  def initialize(site)
    @site = site
  end

  def summary
    summaries.last
  end

  def summaries
    site_summaries.sort_by(&:date)
  end

  def method_missing(name, *args)
    summary.send name, *args rescue @site.send name, *args
  end

  class << self
    def method_missing(name, *args)
      User.send name, *args
    end
  end

  private
    def site_summaries
      @site.user.site_summaries.where(:site_id => @site.id)
    end

end
