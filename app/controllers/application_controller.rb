# coding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @current_user ||= User.where(_id: session[:user_id]).last || User.where(name: 'hibariya').last
  end

  def authenticated?
    current_user.present?
  end

  helper_method :current_user, :authenticated?

  def authenticate_user!
    unless authenticated?
      session[:return_to] = request.fullpath
      redirect_to root_path, notice: 'サインインが必要です'
    end
  end

  # TODO もっといい方法は無いのかね
  def user_safe_path(route, user_name, *args)
    reserved_paths.include?(user_name) ?
      send("safe_#{route}_path", user_name, *args) :
      send("short_#{route}_path", user_name, *args)
  end

  helper_method :user_safe_path

  private

  def reserved_paths
    @reserved_paths ||= Rsss::Application.routes.routes.map {|r|
      r.path.scan(/^\/([^\/\(]+)/)
    }.flatten.uniq
  end
end
