# -*- encoding: utf-8 -*-

module ApplicationHelper

  def signed_in?
    controller.signed_in?
  end

  def string_head(s, len=20, ovrflw='...')
   s.scan(/./)[0..len].join + (s.length>len ? ovrflw: '')
  end

  def specified_screen_name?(screen_name)
    specified_screen_names.include? screen_name
  end

  def user_page_path(user = nil, format = nil)
    part = screen_name user
    specified_screen_name?(part)?
      specified_user_path(:user => part, :format => format):
      user_path(:user => part, :format => format)
  end

  def user_category_page_path(user, category, format = nil)
    part = screen_name user
    specified_screen_name?(part)?
      specified_user_category_path(:user => part, :category => category, :format => format):
      user_category_path(:user => part, :category => category, :format => format)
  end

  def twitter_uri(user=nil)
    "http://twitter.com/#{screen_name(user)}"
  end

  def html_to_tooltip(html)
    html.to_s.gsub(/(<[^>]+>|\s+)/, '')
  end

  def twitter_link(user)
    link_to "#{user.screen_name}(#{user.name})", twitter_uri(user),
      :title => user.screen_name, :target => '_blank'
  end

  def user_site_link(user)
    link_to user.site, user.site, :target => "_blank"
  end

  def category_link(category)
    link = link_to category.name, user_category_path(category.user, category.name), :title => category.name
    saved_score = (1+category.score/2).round
    (<<-EOS).html_safe
      <span class="size_as_#{saved_score}">#{link}</span>
    EOS
  end

  def associate_link(associate)
    user = associate.associate_user
    link = link_to user.screen_name, user_page_path(user), :title => user.auth_profile.name
    # TODO: icon etc..
    (<<-EOS).html_safe
      <div><img src="#{user.auth_profile.profile_image_url}" alt="#{user.auth_profile.name}" /></div>
      <div>#{link}</div>
    EOS
  end

  def entry_link(entry)
    link_to string_head(entry.title, 35), entry.link,
      :target => "_blank", :title => entry.title, :style => 'color: green;'
  end

  def site_link(site)
    link_to site.title, site.site_uri,
      :title => site.title, :class => "color_as_#{site.frequency_score}", :target => "_blank"
  end

  private
    def screen_name(user=nil)
      user ||= current_user
      user.kind_of?(String)? user: user.screen_name
    end

    def escape_param(str)
      CGI.escape(str).gsub(/\./, '%2E').gsub(/\+/, '%20')
    end

    def specified_screen_names
      @specified_screen_names ||= begin
        names = Rsss::Application.routes.named_routes.to_a.map do |route|
          dirname = route.last.path.split(/\//)[1]
          dirname.match(/[a-zA-Z0-9_]+/).to_s
        end
        names.uniq.reject(&:empty?)
      end
    end


end
