module ApplicationHelper
  def string_limit(s, len=20, ovrflw='...')
   s[0..len] + (s.length>len ? ovrflw: '')
  end
end
