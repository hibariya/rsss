# coding: utf-8

class SitesController < ApplicationController
  
  def create
    @site = Site.new params[:site]
    @site.user = current_user.user

    if @site.invalid?
      raise Mongoid::Errors::Validations

    elsif @site.unavailable? && @site.detectable?
      flash[:error] = 'フィードを選択してください'
      render :action => :select_feed

    elsif @site.unavailable?
      flash[:error] = 'フィードが取得できませんでした'
      return redirect_to dashboard_path

    else
      @site.reload_and_save
      @site.user.tap do |user|
        user.reload_site_summaries
        user.reload_categories
        user.reload_category_summaries
      end
      flash[:volatile] = "#{@site.uri} を追加しました"
      return redirect_to dashboard_path
    end

  rescue 
    flash[:error] = '更新に失敗しました'
    return redirect_to dashboard_path
  end

  def update
    if site = current_user.sites.select{|s| s.id.to_s==params[:id] }.first
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
    site = current_user.sites.select{|s| s.id.to_s==params[:id] }.first
    site.delete if site
    flash[:notice_volatile] = "#{site.uri} を削除しました"
    return redirect_to '/dashboard'
  end

end
