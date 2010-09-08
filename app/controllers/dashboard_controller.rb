class DashboardController < ApplicationController
  before_filter ApplicationController.check_signin

  def index
    @user.sites<<Site.new end

  def select_feed
    @site = @user.sites.select{|s| s.id.to_s==params[:id] }.first || Site.new
  end

end
