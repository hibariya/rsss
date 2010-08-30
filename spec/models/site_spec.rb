# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Site do
  context "新規作成" do
    before(:each) do
      @target = Site.make_unsaved
    end

    shared_examples_for "site_invalid_record" do
      it "invalidになること" do
        @target.should_not be_valid
      end
    end

    context "uriがhttp以外のスキーマから始まるとき" do
      before{ @target.uri = 'ftp://hoge.com/piyo' }
      it_should_behave_like "site_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:uri].should_not be_blank
      end
    end

    context "uriの幅が400を超えるとき" do
      before{ @target.uri = 'ftp://hoge.com/piyo'+('a'*400) }
      it_should_behave_like "site_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:uri].should_not be_blank
      end
    end

    context "site_uriの幅が400を超えるとき" do
      before{ @target.site_uri = 'ftp://hoge.com/piyo'+('a'*400) }
      it_should_behave_like "site_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:site_uri].should_not be_blank
      end
    end

    context "titleの幅が200を超えるとき" do
      before{ @target.title = 'あ'*201 }
      it_should_behave_like "site_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:title].should_not be_blank
      end
    end

    context "それら以外のとき" do
      before { @target = Site.make_unsaved }
      
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
