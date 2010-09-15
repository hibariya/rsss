# -*- condig: utf-8 -*-

class History
  include Mongoid::Document

  field :volume_level, :type=>Fixnum, :default=>0
  field :frequency_level, :type=>Fixnum, :default=>0
  field :created_at, :type=>Time
  
  embedded_in :site, :inverse_of=>:histories

  validates :volume_level, :presence=>true, :numericality=>true
  validates :frequency_level, :presence=>true, :numericality=>true
  validate do |h|
    h.errors.add(:volume_level, 'is not Valid') if h.volume_level.to_i>24 || h.volume_level.to_i<0
    h.errors.add(:frequency_level, 'is not Valid') if h.frequency_level.to_i>24 || h.frequency_level.to_i<0
  end

  def general_level
    (volume_level.to_f+frequency_level.to_f)/2 end

end
