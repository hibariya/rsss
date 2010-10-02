class UsersController < ApplicationController

  def index
    @page = (params[:page] || 1).to_i
    @par_page = 10
    @users = User.order_by(:created_at.desc).skip((@page-1).abs*@par_page).limit(@par_page)
    @users_count = User.count
    redirect_to :action=>:index if @users.length==0 && page!=1
    render :layout=>'application'
  end
  
  def update
    check_signin
    session_user.site = params[:user][:site]
    session_user.description = params[:user][:description]
    if session_user.valid?
      session_user.save
      flash[:notice] = "Profile has been changed"
    else
      flash[:notice] = session_user.errors.first.last
    end
    return redirect_to '/dashboard'
  end

end
