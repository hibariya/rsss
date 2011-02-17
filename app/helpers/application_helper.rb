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

  def score(s)
    ((s.to_f/24)*100).round
  end

  def html_to_tooltip(html)
    html.to_s.gsub(/(<[^>]+>|\s+)/, '')
  end

  def upbeat_or_downbeat(site)
    return '⇧' if site.upbeat?
    return '⇩' if site.downbeat?
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

  def color_codes
    %w(#f39700 #e60012 #9caeb7 #00a7db #009944 #d7c447 #9b7cb6 #00ada9
       #bb641d #e85298 #0079c2 #6cbb5a #b6007a #e5171f #522886 #0078ba
       #019a66 #e44d93 #814721 #a9cc51 #ee7b1a #00a0de)
  end

  def graph_data_codes(sites)
    sites.map do |site| 
      history = Array.new 30, 0
      site.summaries.each_with_index{|s,i| history[i] = s.score }
      "g.data('#{site.domain}', #{history[0...30].inspect});"
    end.join("\n")
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
