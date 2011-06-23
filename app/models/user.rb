class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :url,  type: String
  field :bio,  type: String

  index :name, unique: true

  references_many :authentications
  references_many :sites

  embeds_many :tags
  embeds_many :related_users

  validates :name,
    presence: true,
    uniqueness: true,
    length: {maximum: 200}
  validates :url,
    format: URI.regexp(%w(http https)),
    length: {maximum: 200}
  validates :bio, length: {maximum: 400}
end
