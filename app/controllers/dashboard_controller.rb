class DashboardController < ApplicationController
  before_filter ApplicationController.check_signin

  def index
    session_user.sites<<Site.new end

  def select_feed
    @site = session_user.sites.select{|s| s.id.to_s==params[:id] }.first || Site.new
  end

end
