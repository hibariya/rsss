# coding: utf-8

class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :require_user

  rescue_from Exception, :with => :application_error if %w(production).include? Rails.env

  layout 'application'

  def current_user
    return @current_user if @current_user
    user = User.where(:token => session[:user_token]).first
    @current_user ||= user ? UserPresenter.new(user): nil
  end

  def current_user=(user)
    session[:user_token] ||= user.token
    @current_user = user
  end

  def signed_in?
    !!current_user
  end

  def require_user
    raise Rsss::NotAuthorized unless signed_in?
  end

  private
  
    def application_error(e)
      ErrorLog.add e
      flash.now[:error] = error_message(e)
      respond_to do |format|
        format.html do
          render :layout => false, :template => 'error',
                 :status => status_code(e)
        end

        format.rss do
          render :layout => false, :text => '', :status => status_code(e)
        end
      end
    end

    def status_code(e)
      if [ActionController::RoutingError, Rsss::UserNotFoundError, Mongoid::Errors::DocumentNotFound].include? e.class
        404

      elsif [Rsss::NotAuthorized].include? e.class
        403

      else 
        500

      end
    end

    def error_message(e)
      if [ActionController::RoutingError, Rsss::UserNotFoundError, Mongoid::Errors::DocumentNotFound].include? e.class
        'ユーザまたはページが見つかりませんでした。'

      elsif [Rsss::NotAuthorized].include? e.class
        'サインインが必要です'

      else 
        '未分類の内部エラー'

      end
    end

end
