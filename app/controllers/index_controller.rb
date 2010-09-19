class IndexController < ApplicationController
  def index
    render :layout=>'application' end

  def user
    @focus_user = User.find(:first, :conditions=>{:screen_name=>params[:user]})
    unless @focus_user
      flash[:notice] = "No such User or Page"
      render :status=>404, :action=>'error', :layout=>'application'
    end
  end
  
end
