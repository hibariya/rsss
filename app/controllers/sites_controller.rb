# -*- condig: utf-8 -*-

class SitesController < ApplicationController
  before_filter ApplicationController.check_admin
  
  def create
    @user.sites<<Site.new(:uri=>params[:site][:uri])
    unless @user.sites.last.valid?
      flash[:notice] = @user.sites.last.errors.first.last
    else
      return false unless check_feed @user.sites.last
      @user.save
      @user.create_histories rescue nil
    end
    return redirect_to '/dashboard'
  end

  def update
    if site = @user.sites.select{|s| s.id.to_s==params[:id] }.first
      site.uri = params[:site][:uri]
      unless site.valid?
        flash[:notice] = site.errors.first
      else
        return false unless check_feed site
        site.save
        @user.create_histories rescue nil
      end
    end
    return redirect_to '/dashboard'
  end

  def destroy
    site = @user.sites.select{|s| s.id.to_s==params[:id] }.first
    site.delete if site
    return redirect_to '/dashboard'
  end

  private
  def check_feed(site)
    begin 
      site.load_channel_info
      true
    rescue Exception=>e 
      # RSSとして読み込むのに失敗したんだろう
      flash[:feeds] = []
      begin
        agent = Mechanize.new
        agent.get site.uri
        agent.page.root.search('link').find_all{|l| l.attributes['rel'].to_s=='alternate' }.each do |link|
          c = Site.new(:uri=>link.attributes['href'].to_s).load_channel_info
          flash[:feeds]<<[c.title, c.uri] rescue next # 同じくRSSとして読み込めなかった
        end
      rescue
        # Mechanizeでごにょごにょしてるときに事故がおきたか
      end

      if flash[:feeds].empty?
        flash[:notice] = 'LoadError'
        redirect_to '/dashboard'
      else
        redirect_to '/dashboard/select_feed/'+site.id.to_s unless flash[:feeds].empty?
      end
      false
    end
  end
end
