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
    screen_name = username || session_user.try(:screen_name)
    specified_screen_name?(screen_name)?
      ['/user/', screen_name].join:
      ['/', screen_name].join
  end

  def specified_screen_name?(screen_name)
    controller.specified_controllers.include?(screen_name)
  end

  def twitter_uri(username='')
    ['http://twitter.com/', username].join
  end

end
