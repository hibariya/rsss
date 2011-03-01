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
    summary.score > (before_summary.try(:score) || 0)
  end

  def downbeat?
    summary.score < (before_summary.try(:score) || 0)
  end

  def domain
    @domain ||= URI.parse(@site.uri).host
  end

  def entries_each
    entries[0..resize_score(score)].each do |entry|
      yield entry
    end
  end

  def feed(version='1.0')
    RSS::Maker.make version do |maker|
      maker.channel.title    = maker.channel.description = title
      maker.channel.about    = uri
      maker.channel.link     = site_uri
      maker.channel.date     = Time.now #
      maker.channel.author   = user.screen_name
      maker.channel.language = 'ja' # TDOO
      maker.image.url        = ''
      maker.image.title      = ''
      maker.items.do_sort    = true

      entries.each do |entry|
        maker.items.new_item do |item|
          %w(link title date description).each do |attr|
            item.send "#{attr}=", entry.send(attr)
          end

          entry.categories.each do |category_name|
            item.categories.new_category{|c| c.content = c.term = category_name }
            item.dc_subjects.new_subject{|c| c.value = category_name }
          end
        end
      end
    end
  end

  # TODO: remove 
  def method_missing(name, *args)
    summary.respond_to?(name)?
      summary.send(name, *args):
      @site.send(name, *args)
  end

  class << self
    delegate :model_name, :to => Site
  end

  private
    def resize_score(score, max=5)
      ((score.to_f/25) * max).round
    end

    def site_summaries
      @site_summaries ||= user.site_summaries.where(:site_id => @site.id)
    end

end
