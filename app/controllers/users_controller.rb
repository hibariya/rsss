# -*- encoding: utf-8 -*-

class UsersController < ApplicationController

  def index
    @users_count = User.count
    @users = User.page(params[:page]).per(10)
    render :layout=>'application'
  end
  
  def update
    check_signin
    current_user.site = params[:user][:site]
    current_user.description = params[:user][:description]
    if current_user.valid?
      current_user.save
      flash[:notice_volatile] = "RSSSのプロフィールを変更しました"
    else
      flash[:notice] = current_user.errors.to_a.join
    end
    return redirect_to '/dashboard'
  end

end
