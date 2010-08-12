class SitesController < ApplicationController
  before_filter ApplicationController.check_admin
  
  def create
    @user.sites<<Site.new(:uri=>params[:site][:uri])
    unless @user.sites.last.valid?
      flash[:notice] = @user.sites.last.errors.first.last
    else
      @user.save
      @user.create_histories
    end
    return redirect_to '/dashboard'
  end

  def update
    if site = @user.sites.select{|s| s.id.to_s==params[:id] }.first
      site.uri = params[:site][:uri]
      unless site.valid?
        flash[:notice] = site.errors.first
      else
        site.save
        @user.create_histories
      end
    end
    return redirect_to '/dashboard'
  end

  def destroy
    site = @user.sites.select{|s| s.id.to_s==params[:id] }.first
    site.delete if site
    return redirect_to '/dashboard'
  end

end
