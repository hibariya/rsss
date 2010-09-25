module ApplicationHelper
  extend self

  def string_limit(s, len=20, ovrflw='...')
   s.scan(/./)[0..len].join + (s.length>len ? ovrflw: '')
  end

  def session_user
    controller.session_user
  end
  
  def signin?
    !session_user.nil?
  end

  def user_page_path(username=nil)
    controller.user_page_path(username) end

  def user_feed_path(username=nil)
    controller.user_feed_path(username) end

  def twitter_uri(username='')
    ['http://twitter.com/', username].join
  end

end
