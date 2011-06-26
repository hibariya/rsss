class Site::History
  MAX_HISTORIES = 30

  include Mongoid::Document

  field :volume_score,    type: Fixnum, default: 0
  field :frequency_score, type: Fixnum, default: 0
  field :created_on,      type: Date

  embedded_in :site, inverse_of: :histories
end
