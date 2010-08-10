class DashboardController < ApplicationController
  before_filter do
    if session[:token]
      load_user User.find(:first, :conditions=>{:token=>session[:token]}).screen_name
    end

    if @user.nil?
      flash[:notice] = "Authentication failed"
      return redirect_to :controller=>:auth, :action=>:failure
    end
  end

  def index
  end

  def edit
  end

end
