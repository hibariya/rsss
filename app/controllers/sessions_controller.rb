# encoding: utf-8

class SessionsController < ApplicationController

  def create
    return failure unless user_info

    current_user = UserPresenter.new load_user || create_user
    redirect_to dashboard_path, :notice => 'サインインしました'

  rescue
    failure
  end

  def signout
    session.clear
    return redirect_to '/', :notice => 'サインアウトしました'
  end

  private
    def failure
      render :action => :failure, :status => 403, :notice => 'サインインに失敗しました'
    end

    def load_user
      User.by_user_id(user_info['user_id']).first
    end

    def create_user
      user = User.new
      tokens = credentials.slice *%w(token secret)
      user.auth_profile = AuthProfile.new tokens.merge(:user_info => user_info)
      user.update_token
      user.auth_profile.reload_and_save_profile
    end

    def user_info
      auth['user_info']
    end

    def credentials
      auth['credentials']
    end

    def auth
      @auth ||= request.env['rack.auth'] || {}
    end
end
