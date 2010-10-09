# -*- encoding: utf-8 -*-

class SummarizedCategory
  include Mongoid::Document

  field :category, :type=>String
  field :level, :type=>Fixnum

  embedded_in :user, :inverse_of=>:summarized_categories
end
