# -*- encoding: utf-8 -*-

class Category
  include Mongoid::Document
  field :name, :type=>String
  field :frequency, :type=>Float
  index :name, :unique=>true, :background=>true

  referenced_in :user
end
