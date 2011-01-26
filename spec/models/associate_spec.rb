# -*- coding: utf-8 -*-

require 'spec_helper'

describe Associate, :clear=>true do
  before :all do
    @alice = Fabricate :user
    @cliff = Fabricate :user
  end

  describe ".create" do
    before do
      @associate = Associate.create :user=>@alice, :score=>10.5, :associate_user=>@cliff
    end

    it "作成できる" do
      @associate.should be_kind_of Associate
      @alice.associates.should be_include @associate
    end
  end

  describe "関連するドキュメント" do
    before do
      @associate = Associate.last
    end

    it "ユーザが取得できる" do
      @associate.user.should be_kind_of User
    end
  end
end

