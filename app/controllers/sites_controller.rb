# coding: utf-8

class SitesController < ApplicationController
  
  def create
    @site = Site.new :uri => params[:site][:uri], :user => current_user.user
    create_or_update
  end

  def update
    @site = current_user.sites.find params[:id]
    create_or_update
  end

  def destroy
    @site = current_user.sites.find params[:id]
    @site.destroy
    flash[:volatile] = "#{@site.uri} を削除しました"
    redirect_to dashboard_path
  end

  private 

    def create_or_update # :nodoc:
      if @site.invalid?
        raise Mongoid::Errors::Validations
  
      elsif @site.unavailable? && @site.detectable?
        flash[:error] = 'フィードを選択してください'
        render :action => :select_feed
  
      elsif @site.unavailable?
        flash[:error] = 'フィードが取得できませんでした'
        return redirect_to dashboard_path
  
      else
        create_first_summary
        flash[:volatile] = "#{@site.uri} を保存しました"
        return redirect_to dashboard_path
      end

    rescue 
      flash[:error] = '更新に失敗しました'
      return redirect_to dashboard_path
    end

    def create_first_summary # :nodoc:
      @site.reload_and_save
      @site.user.tap do |user|
        user.reload_site_summaries
        user.reload_categories
        user.reload_category_summaries
      end
    end

end
