class Article
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url,          type: String
  field :title,        type: String
  field :content,      type: String
  field :tags,         type: Array
  field :published_at, type: Time

  index :date
  index :site_id

  scope :until_yesterday, -> { where(:date.lt => Time.now.beginning_of_day) }

  embedded_in :site, inverse_of: :articles

  validates :url, format: URI.regexp(%w(http https)), length: {maximum: 200}
  validates :title, length: {maximum: 400}
  validates :content, length: {maximum: 10000}

  alias_method :raw_title, :title

  def title
    sanitizer.strip_tags raw_title
  end

  alias_method :raw_content, :content

  def content
    sanitizer.strip_tags raw_content
  end

  def content_length
    title.length + content.length
  end

  private

  def sanitizer
    self.class.sanitizer
  end

  class << self
    extend ActiveSupport::Memoizable

    def sanitizer
      Class.new { include ActionView::Helpers::SanitizeHelper }.new
    end

    memoize :sanitizer
  end
end
