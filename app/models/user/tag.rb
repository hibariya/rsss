class User::Tag
  include Mongoid::Document

  field :name,      type: String
  field :frequency, type: Fixnum

  embedded_in :user, inverse_of: :tags

  validates :name, presence: true, uniqueness: true, length: {maximum: 200}
end
