# coding: utf-8

class IndexController < ApplicationController
  def index
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
