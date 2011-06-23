class RelatedUser
  include Mongoid::Document

  field :name,      type: String
  field :frequency, type: Float

  embedded_in :user, inverse_of: :related_users

  validates :name,
    presence: true,
    uniqueness: true,
    length: {maximum: 200}
end
