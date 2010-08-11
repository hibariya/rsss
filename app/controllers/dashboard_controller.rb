class DashboardController < ApplicationController
  before_filter ApplicationController.check_admin

  def index; end
end
