class IndexController < ApplicationController
  before_filter do
    load_user params[:user] || 'pussy_cat'
  end

  def index
  end

  def test
    `rails runner "User.all.each do |user|
      user.create_histories
    end"`

    redirect_to '/'
  end

end
