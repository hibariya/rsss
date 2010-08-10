class History
  include Mongoid::Document

  field :volume_level, :type=>Fixnum
  field :frequency_level, :type=>Fixnum
  field :created_at, :type=>Time
  embedded_in :site, :inverse_of=>:histories

  def general_level
    (volume_level.to_f+frequency_level.to_f)/2 end

end
