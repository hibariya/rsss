class IndexController < ApplicationController
  def index
    @user = User.all.last
    
  end

  def test
    `rails runner "User.all.each do |user|
      user.reload_summaries
    end"`

    redirect_to '/'
  end

end
