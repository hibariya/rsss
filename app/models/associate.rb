# -*- encoding: utf-8 -*-

class Associate
  include Mongoid::Document

  field :associate_user_id, :type => BSON::ObjectId
  field :score,             :type => Float

  referenced_in :user

  def associate_user
    User.find associate_user_id
  end

  def associate_user=(user)
    self.associate_user_id = user.id
  end
end
