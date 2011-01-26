# -*- coding: utf-8 -*-

require 'spec_helper'

describe Category, :clear=>true do
  before :all do
    @alice = Fabricate :user
  end

  describe ".create" do
    before do
      @category = Category.create :user=>@alice, :frequency=>10.5, :name=>'cat'
    end

    it "作成できる" do
      @category.should be_kind_of Category
      @alice.categories.should be_include @category
    end
  end

  describe "関連するドキュメント" do
    before do
      @category = Category.last
    end

    it "ユーザが取得できる" do
      @category.user.should be_kind_of User
    end
  end
end

