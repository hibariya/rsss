module ApplicationHelper
  def string_limit(s, len=20, ovrflw='...')
   s.scan(/./)[0..len].join + (s.length>len ? ovrflw: '')
  end

  def signin?
    @signin ||= !User.find_by_token(session[:token]).nil?
  end

  def user_page_path
    ['/', @user.try(:screen_name)].join
  end
end
