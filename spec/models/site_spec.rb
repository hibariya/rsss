# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Site do
  context "新規作成" do
    before do
      @target = (User.make.sites<<Site.make_unsaved).last
    end

    context "uriがhttp以外のスキーマから始まるとき" do
      before{ @target.uri = 'ftp://hoge.com/piyo' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:uri].should_not be_blank
      end
    end

    context "uriの幅が400を超えるとき" do
      before{ @target.uri = 'http://hoge.com/piyo'+('a'*400) }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:uri].should_not be_blank
      end
    end

    context "uriが空のとき" do
      before{ @target.uri = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:uri].should_not be_blank
      end
    end

    context "site_uriの幅が400を超えるとき" do
      before{ @target.site_uri = 'https://hoge.com/piyo'+('a'*400) }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:site_uri].should_not be_blank
      end
    end

    context "site_uriが空のとき" do
      before{ @target.site_uri = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:site_uri].should_not be_blank
      end
    end

    context "titleの幅が200を超えるとき" do
      before{ @target.title = 'あ'*201 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:title].should_not be_blank
      end
    end

    context "titleが空のとき" do
      before{ @target.title = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:title].should_not be_blank
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
