# -*- condig: utf-8 -*-

class RecentEntry
  include Mongoid::Document

  field :title, :type=>String
  field :content, :type=>String
  field :link, :type=>String
  field :date, :type=>Time

  validates :title, :presence=>true, :length=>{:maximum=>200}
  validates :content, :length=>{:maximum=>5000}
  validates :link, :presence=>true, :length=>{:maximum=>400}, :format=>/^https?:\/\/.+$/

  embedded_in :site, :inverse_of=>:recent_entries
end
