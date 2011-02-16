class SitePresenter
  attr_accessor :site

  def initialize(site, user=nil)
    @site, @user = site, user
  end

  def user
    @user ||= site.user
  end

  def summary
    summaries.last
  end

  def before_summary
    summaries[-2]
  end

  def summaries
    site_summaries.sort_by(&:date)
  end

  def summaries?
    !summaries.empty?
  end

  def upbeat?
    summary.score > before_summary.score
  end

  def downbeat?
    summary.score < before_summary.score
  end

  def domain
    @domain ||= URI.parse(@site.uri).host
  end

  # TODO: remove 
  def method_missing(name, *args)
    summary.respond_to?(name)?
      summary.send(name, *args):
      @site.send(name, *args)
  end

  private
    def site_summaries
      @site_summaries ||= user.site_summaries.where(:site_id => @site.id)
    end

end
