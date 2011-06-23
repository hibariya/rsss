class Authentication
  include Mongoid::Document
  include Mongoid::Timestamps

  field :provider, type: Symbol
  field :uid,      type: String

  index [:provider, :uid], unique: true

  referenced_in :user

  validates :provider, presence: true
  validates :uid, presence: true
end
