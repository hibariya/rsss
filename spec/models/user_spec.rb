require 'spec_helper'

describe User do
  context "新規作成" do
    before do
      @target = User.new
      @valid_attributes = {:screen_name=>'',
        :description=>'',
        :site=>'',
        :created_at=>Time.now,
        :updated_at=>Time.now,
        :oauth_user_id=>10,
        :oauth_token=>'foobar',
        :oauth_secret=>'foo',
        :token=>''}
    end

    it "保存できる" do
      @target.attributes = @valid_attributes
      @target.save.should be_true
    end


  end
end
