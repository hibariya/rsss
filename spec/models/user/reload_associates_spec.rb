# -*- encoding: utf-8 -*-
require 'spec_helper'

describe 'User#reload_associates', :clear => true do
  let!(:target){ Fabricate :user }

  before :all do
    10.times { Fabricate :user }
    User.all.each do |user|
      user.reload_categories
      user.save
    end
    target.reload_associates
    target.save
  end

  it "自分以外のユーザすべてのassociateが作成されていること" do
    target.associates.length.should eql (User.all.length-1)
  end

  it "各ユーザとのカテゴリマッチ数が正しく更新されている" do
    target.associates.each do |associate|
      matches = associate.associate_user.categories.to_a & target.categories.to_a
      associate.score.should eql matches.length.to_f
    end
  end
end

