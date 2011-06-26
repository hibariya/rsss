class Site
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title,           type: String
  field :url,             type: String
  field :feed_url,        type: String
  field :volume_score,    type: Float
  field :frequency_score, type: Float

  validates :title, length: {maximum: 400}
  validates :url, format: URI.regexp(%w(http https)), length: {maximum: 200}
  validates :feed_url, presence: true, format: URI.regexp(%w(http https)), length: {maximum: 400}

  embeds_many :articles do
    def content_volume
      until_yesterday.map(&:content_length).sum / time_length
    end

    def content_frequency
      until_yesterday.count / time_length
    end

    def time_length
      times  = until_yesterday.map(&:date).sort
      border = Time.now.beginning_of_day
      (border - times.first).to_f.abs
    end

    def by_url(url)
      where(url: url).first
    end
  end

  def sync!
    feed = Feedzirra::Feed.fetch_and_parse(url)
    update_attributes! title:    feed.title,
                       url:      feed.url,
                       feed_url: feed.feed_url
    sync_articles! feed
  end

  def sync_articles!(feed)
    feed.entries.map do |entry|
      article = articles.by_url(entry.url) || Article.new(site: self, url: entry.url)
      article.title     = entry.title
      article.content   = entry.content || entry.summary
      article.tags      = entry.categories
      article.published = entry.published
    end

    save!

    articles.not_in(feed.entries.map(&:url)).map(&:destroy)
  end
end
