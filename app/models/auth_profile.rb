# -*- encoding: utf-8 -*-

class AuthProfile

  include Mongoid::Document

  field :screen_name,       :type=>String
  field :user_id,           :type=>String
  field :token,             :type=>String
  field :secret,            :type=>String
  field :description,       :type=>String
  field :name,              :type=>String
  field :profile_image_url, :type=>String

  attr_writer :user_info

  embedded_in :user, :inverse_of=>:auth_profile
  
  index :screen_name, :unique=>true,  :background=>true
  index :token,       :unique=>false, :background=>true
  index :secret,      :unique=>false, :background=>true

  validates :screen_name,       :presence=>true,          :length=>{:maximum=>60},       :format=>/^[a-zA-Z0-9_\.]*$/
  validates :user_id,           :presence=>true,          :length=>{:within=>1..100},    :format=>/^[0-9]+$/
  validates :token,             :presence=>true,          :length=>{:within=>1..100},    :format=>/^[0-9a-zA-Z\-]+$/
  validates :secret,            :presence=>true,          :length=>{:within=>1..100},    :format=>/^[0-9a-zA-Z]+$/
  validates :description,       :length=>{:maximum=>400}
  validates :name,              :length=>{:maximum=>60}
  validates :profile_image_url, :length=>{:maximum=>400}, :format=>URI.regexp(['http']), :allow_blank=>true

  def user_info
    @user_info ||= Rsss::Twitter.user_info token, secret
  end
  
  # 指定されたログイン名を既に使用しているユーザを更新
  def swap(screen_name)
    to = User.where('auth_profile.screen_name'=>screen_name).first
    return if [nil, self].include? to
    to.reload_profile
  end

  # ユーザログイン、description, 名前、プロフィール画像の更新
  def reload_and_save_profile
    return false unless new_screen_name = user_info['screen_name']
    swap new_screen_name unless screen_name==new_screen_name

    self.screen_name       = new_screen_name
    self.profile_image_url = user_info['profile_image_url']
    self.name              = user_info['name']
    self.description       = user_info['description']
    self.save!
  end

end
