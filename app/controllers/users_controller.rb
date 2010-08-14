class UsersController < ApplicationController
  before_filter ApplicationController.check_admin
  
  def update
    @user.site = params[:user][:site]
    @user.description = params[:user][:description]
    if @user.valid?
      @user.save
    else
      flash[:notice] = @user.errors.first.last
    end
    return redirect_to '/dashboard'
  end

end
