# -*- condig: utf-8 -*-

class SummarizedNearUser
  include Mongoid::Document

  field :screen_name, :type=>String
  field :level, :type=>Fixnum

  embedded_in :user, :inverse_of=>:summarized_near_users
end
