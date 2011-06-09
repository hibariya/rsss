# -*- encoding: utf-8 -*-

class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  before_filter do
    if request.env['SERVER_NAME']=='rsss.heroku.com'
      redirect_to ['http://rsss.be/', params[:user] || ''].join, :status=>301
      return false
    end
  end

  rescue_from Exception do |e|
    logger.debug e.class
    logger.debug e.message
    logger.debug e.backtrace
    respond_to do |format|
      format.html{ render :controller=>:index, :action=>:failure }
      format.xml{ render :controller=>:index, :action=>:failure, :layout=>false }
    end
  end if Rails.env=='production'

  def specified_controllers; %w(auth dashboard user sites users index updates) end
  def session_user
    @session_user ||= session[:token] && User.by_token(session[:token]).first rescue nil
  end

  def check_signin
    if session_user.nil?
      redirect_to :controller=>:auth, :action=>:failure
    end
  end

  def user_page_path(username=nil)
    screen_name = username || session_user.try(:screen_name)
    specified_screen_name?(screen_name)?
      ['/user/', screen_name].join:
      ['/', screen_name].join
  end

  def user_feed_path(username=nil)
    [user_page_path(username), '.rss'].join
  end

  def specified_screen_name?(screen_name)
    specified_controllers.include?(screen_name)
  end
end
