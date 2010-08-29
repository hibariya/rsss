# -*- condig: utf-8 -*-

class RecentEntry
  include Mongoid::Document

  field :title, :type=>String
  field :content, :type=>String
  field :link, :type=>String
  field :date, :type=>Time

  embedded_in :site, :inverse_of=>:recent_entries
end
