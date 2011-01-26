# -*- encoding: utf-8 -*-

class SitesController < ApplicationController
  before_filter :check_signin
  
  def create
    session_user.sites<<Site.new(:uri=>params[:site][:uri])
    unless session_user.sites.last.valid?
      flash[:notice] = session_user.sites.last.errors.to_a.join
    else
      return false unless check_feed session_user.sites.last
      flash[:notice_volatile] = "#{session_user.sites.last.uri} を追加しました"
      session_user.save
      session_user.create_histories!
      #session_user.be_skinny!
    end
    return redirect_to '/dashboard'
  end

  def update
    if site = session_user.sites.select{|s| s.id.to_s==params[:id] }.first
      site.uri = params[:site][:uri]
      unless site.valid?
        flash[:notice] = site.errors.to_a.join
      else
        return false unless check_feed site
        flash[:notice_volatile] = "#{site.uri} を保存しました"
        site.save
        site.user.create_histories!
        #site.user.be_skinny!
      end
    end
    return redirect_to '/dashboard'
  end

  def destroy
    site = session_user.sites.select{|s| s.id.to_s==params[:id] }.first
    site.delete if site
    flash[:notice_volatile] = "#{site.uri} を削除しました"
    return redirect_to '/dashboard'
  end

  private
  def check_feed(site)
    begin 
      site.load_channel_info
      true
    rescue Exception=>e 
      flash[:feeds] = [] 
      begin
        agent = Mechanize.new
        agent.get site.uri
        agent.page.root.search('link').find_all{|l| l.attributes['rel'].to_s=='alternate' }.each do |link|
          c = Site.new(:uri=>URI.join(site.uri, link.attributes['href'].to_s).to_s).load_channel_info
          flash[:feeds]<<[c.title, c.uri] rescue next
        end
      rescue
      end

      if flash[:feeds].empty?
        flash[:notice] = 'フィードの取得に失敗しました'
        redirect_to '/dashboard'
      else
        redirect_to '/dashboard/select_feed/'+site.id.to_s unless flash[:feeds].empty?
      end
      false
    end
  end
end
