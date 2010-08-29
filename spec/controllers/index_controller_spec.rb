# -*- encoding: utf-8 -*-
require 'spec_helper'

describe IndexController, 'GET /:user' do

#  it "/:userでindexコントローラのuserアクションにリクエストされること" do
#    {:get=>'/pussy_cat'}.should route_to(:controller=>'index', :action=>'user', :user=>'pussy_cat')
#  end

  it "リクエストは成功すること" do
    get 'user', {:user=>'pussy_cat'}
    #get '/pussy_cat'

    #puts response.inspect
    #response.should be_success
  end

end
