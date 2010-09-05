# -*- encoding: utf-8 -*-
require 'spec_helper'

describe RecentEntry do
  context "新規作成" do
    before(:each) do
      @target = (User.make.sites.first.recent_entries<<RecentEntry.make_unsaved).last
    end

    context "titleの幅が200以上のとき" do
      before{ @target.title = 'あ'*201 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:title].should_not be_blank
      end
    end

    context "contentの幅が5000以上のとき" do
      before{ @target.content = 'あ'*5001 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:content].should_not be_blank
      end
    end

    context "linkがhttpのスキーマではないとき" do
      before{ @target.link = 'ssh://foo.org/' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:link].should_not be_blank
      end
    end

    context "それら以外のとき" do
      it "validationエラーにはならない" do
        @target.should be_valid
        @target.errors.length.should==0
      end
  
      it "保存することができる" do
        @target.save.should be_true
      end
    end
  end

end
