# -*- encoding: utf-8 -*-

class DashboardController < ApplicationController

  def index
    current_user.sites
  end

  def select_feed
    @site = current_user.sites.select{|s| s.id.to_s==params[:id] }.first || Site.new
  end

end
