# -*- encoding: utf-8 -*-

class CategorySummary
  include Mongoid::Document
  include Rsss::Summary
  max_documents 30
  
  field :category_id, :type=>BSON::ObjectId
  field :frequency_score, :type=>Fixnum

  embedded_in :user, :inverse_of=>:category_summaries

  alias score frequency_score
end
