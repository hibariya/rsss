# -*- encoding: utf-8 -*-

class Category
  include Mongoid::Document
  field :name,      :type => String
  field :frequency, :type => Float
  index :name, :unique => true, :background => true

  referenced_in :user

  validates :name, :presence => true
  before_save :name_filter

  private
  def name_filter
    self.name = name.downcase
  end
end
