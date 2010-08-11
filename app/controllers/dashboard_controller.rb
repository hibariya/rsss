class DashboardController < ApplicationController
  before_filter ApplicationController.check_admin

  def index
    @user.sites<<Site.new end

end
