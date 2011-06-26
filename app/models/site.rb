class Site
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title,           type: String
  field :url,             type: String
  field :feed_url,        type: String
  field :volume_score,    type: Fixnum
  field :frequency_score, type: Fixnum

  validates :title, length: {maximum: 400}
  validates :url, format: URI.regexp(%w(http https)), length: {maximum: 200}
  validates :feed_url, presence: true, format: URI.regexp(%w(http https)), length: {maximum: 400}

  referenced_in :user

  embeds_many :histories, class_name: Site::History.to_s do
    def archive!(attrs)
      attrs = {created_on: Date.today}.merge(attrs)

      create! attrs

      max_histories = Site::History::MAX_HISTORIES
      if count > max_histories
        desc(:created_on)[max_histories.pred..-1].map(&:destroy)
      end
    end
  end

  embeds_many :articles do
    def content_volume
      until_yesterday.map(&:content_length).sum / time_length
    end

    def content_frequency
      until_yesterday.count / time_length
    end

    def time_length
      times  = until_yesterday.map(&:published_at).sort
      border = Time.now.beginning_of_day
      (border - times.first).to_f.abs
    end

    def by_url(url)
      where(url: url).first
    end
  end

  def score
    ((frequency_score + volume_score).to_f / 2).round
  end

  def sync!
    feed = Feedzirra::Feed.fetch_and_parse(feed_url)

    update_attributes! title:    feed.title,
                       url:      feed.url,
                       feed_url: feed.feed_url
    sync_articles! feed
  end

  def sync_articles!(feed)
    feed.entries.map do |entry|
      article = articles.by_url(entry.url) || Article.new(site: self, url: entry.url)

      article.title        = entry.title
      article.content      = entry.content || entry.summary
      article.tags         = entry.categories + entry.subjects
      article.published_at = entry.published
    end

    save!
    articles.not_in(url: feed.entries.map(&:url)).map(&:destroy)
  end

  def tags
    articles.map(&:tags).flatten.compact.map(&:downcase)
  end
end
