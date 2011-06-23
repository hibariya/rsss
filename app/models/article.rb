class Article
  include Mongoid::Document

  field :title,   type: String
  field :url,     type: String
  field :date,    type: String
  field :content, type: String
  field :tags,    type: Array

  index :date

  referenced_in :site

  validates :title, length: {maximum: 400}
  validates :url,
    format: URI.regexp(%w(http https)),
    length: {maximum: 200}
  validates :content, length: {maximum: 10000}
end
