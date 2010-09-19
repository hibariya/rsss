module ApplicationHelper
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
    ['/', (username || session_user.try(:screen_name))].join
  end

  def twitter_uri(username='')
    ['http://twitter.com/', username].join
  end

end
