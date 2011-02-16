# -*- encoding: utf-8 -*-

class SiteSummary
  include Mongoid::Document
  include Rsss::Summary
  max_documents 30

  field :site_id,         :type => BSON::ObjectId
  field :frequency_score, :type => Fixnum
  field :volume_score,    :type => Fixnum

  embedded_in :user, :inverse_of => :site_summaries

  def frequency_score
    attributes[:frequency_score] || 0
  end

  def volume_score
    attributes[:volume_score] || 0
  end

  def score
    ((frequency_score + volume_score).to_f / 2).round
  end
end
