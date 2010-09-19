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

  def user_page_path
    ['/', session_user.try(:screen_name)].join
  end

end
