# coding: utf-8

class MiscController < ApplicationController
  skip_before_filter :require_user

  def about
    render :layout=>'application' end
 
  #
  # プロダクトのアップデートをリアルタイム表示
  #
  def updates
    @entries = Rsss::Rss.get('https://github.com/hibariya/rsss/commits/master.atom').
      items.map{|item| Rsss::Rss::Entry.new(item) } rescue []
    render :layout=>'application'
  end

end
