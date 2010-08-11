class SitesController < ApplicationController
  before_filter ApplicationController.check_admin
  
  def create
    @user.sites<<Site.new(:uri=>params[:site][:uri])
    @user.save
    @user.create_histories
    return redirect_to '/dashboard'
  end

  def update
    if site = @user.sites.select{|s| s.id.to_s==params[:id] }.first
      site.uri = params[:site][:uri]
      site.save
    end
    return redirect_to '/dashboard'
  end

  def destroy
    site = @user.sites.select{|s| s.id.to_s==params[:id] }.first
    site.delete if site
    return redirect_to '/dashboard'
  end

end
