require 'spec_helper'

describe Users::SitesController do

  describe "GET 'update'" do
    it "should be successful" do
      get 'update'
      response.should be_success
    end
  end

end
