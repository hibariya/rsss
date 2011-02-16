# -*- encoding: utf-8 -*-

require 'spec_helper'

describe 'User#reload_profile', :clear=>true do
  let!(:target){ Fabricate :user }

  context "Twitterのscreen_nameの変更とscreen_nameが重複していたとき" do
    let!(:duplicate_user){ Fabricate :user, :screen_name => 'duplicate_name' }
    let!(:duplicate_name){ duplicate_user.screen_name }
    let!(:new_name_for_duplicate_user){ 'new_name_for_dup' }

    it "順番に解決される" do
      target.auth_profile.instance_variable_set :@user_info, {
        'screen_name'       =>duplicate_name,
        'description'       =>target.auth_profile.description,
        'name'              =>target.auth_profile.name,
        'profile_image_url' =>target.auth_profile.profile_image_url
      }

      duplicate_user.auth_profile.instance_variable_set :@user_info, {
        'screen_name'       =>new_name_for_duplicate_user,
        'description'       =>duplicate_user.auth_profile.description,
        'name'              =>duplicate_user.auth_profile.name,
        'profile_image_url' =>duplicate_user.auth_profile.profile_image_url
      }
      stub(User).where('auth_profile.screen_name' => duplicate_name){ [duplicate_user] }
      stub(User).where('auth_profile.screen_name' => new_name_for_duplicate_user){ [] }

      target.reload_profile
      target.reload
      duplicate_user.reload

      duplicate_user.screen_name.should_not eql duplicate_name
      duplicate_user.screen_name.should     eql new_name_for_duplicate_user
      target.screen_name.should             eql duplicate_name
    end
  end

  context "ふつうの更新" do
    it "対象のユーザのみ更新される" do
      target.auth_profile.instance_variable_set :@user_info, {
        'screen_name'       => 'new_screen_name',
        'description'       => 'new_description',
        'name'              => 'new_name',
        'profile_image_url' => 'http://new_profile/image_url'
      }

      target.reload_profile
      auth_profile = target.auth_profile
      auth_profile.screen_name.should       eql auth_profile.user_info['screen_name']
      auth_profile.name.should              eql auth_profile.user_info['name']
      auth_profile.description.should       eql auth_profile.user_info['description']
      auth_profile.profile_image_url.should eql auth_profile.user_info['profile_image_url']
    end
  end

end

