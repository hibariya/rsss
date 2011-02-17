# -*- encoding: utf-8 -*-

class UsersController < ApplicationController
  skip_before_filter :require_user, :only => [:index, :show, :category]

  def index
    @users = User.page(params[:page]).per(10)
    render :layout => 'application'
  end

  def show
    @user = UserPresenter.load params[:user]
    raise Rsss::UserNotFoundError unless @user
   
    respond_to do |format|
      format.html
      format.xml { render :text => @user.to_feed.to_s }
    end
  end

  def category
    @user = UserPresenter.load params[:user]
    raise Rsss::UserNotFoundError unless @user
    
    @category = params[:category].downcase
    @entries = @user.recent_entries_by_category @category
    respond_to do |format|
      format.html
      format.xml { render :text => @user.category_feed(@category).to_s }
    end
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
