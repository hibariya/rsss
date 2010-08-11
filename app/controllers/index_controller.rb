class IndexController < ApplicationController
  before_filter do
    load_user params[:user] || 'pussy_cat'
  end

  def index
  end
  
end
