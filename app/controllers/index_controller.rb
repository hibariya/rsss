class IndexController < ApplicationController
  before_filter do
    load_user params[:user]
  end

  def index
    render :layout=>'application' end

  def user
    unless @user
      flash[:notice] = "No such User or Page"
      render :status=>404, :action=>'error', :layout=>'application'
    end
  end
  
end
