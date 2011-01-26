# -*- encoding: utf-8 -*-

class AssociateSummary
  include Mongoid::Document
  include Rsss::Summary
  max_documents 30

  field :associate_id, :type=>BSON::ObjectId
  field :score, :type=>Fixnum

  embedded_in :user, :inverse_of=>:associate_summaries
end
