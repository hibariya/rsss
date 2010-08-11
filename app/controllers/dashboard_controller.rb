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
    if params[:submit]
      site = @user.sites.select{|s| s.id.to_s==params[:site][:id] }.first
      if site
        site.uri = params[:site][:uri]
        site.save
      else
        @user.sites<<Site.new(uri: params[:site][:uri])
        @user.save
      end
      return redirect_to :action=>:index
    end

    if params[:delete]
      site = @user.sites.select{|s| s.id.to_s==params[:site][:id] }.first
      site.delete if site
      return redirect_to :action=>:index
    end
  end

  def edit
  end

end
