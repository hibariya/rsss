class UsersController < ApplicationController
  def index
  end

  def show
  end

  def update
    current_user.update_attributes! params.slice(:bio, :url)
    render json: {message: 'Your changes have been saved'}
  rescue
    render json: {message: 'Failed to save'}
  end

  def category
  end
end
