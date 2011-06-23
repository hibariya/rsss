class Site
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title,    type: String
  field :url,      type: String
  field :feed_url, type: String

  references_many :articles

  validates :title, length: {maximum: 400}
  validates :url,
    format: URI.regexp(%w(http https)),
    length: {maximum: 200}
  validates :feed_url,
    presence: true,
    format: URI.regexp(%w(http https)),
    length: {maximum: 400}
end
