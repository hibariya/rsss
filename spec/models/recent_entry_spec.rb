# -*- encoding: utf-8 -*-
require 'spec_helper'

describe RecentEntry do
  context "新規作成" do
    before(:each) do
      @target = RecentEntry.make_unsaved
    end

    shared_examples_for "recent_entry_invalid_record" do
      it "invalidとなり保存できない" do
        @target.should_not be_valid
        @target.save.should be_false
      end
    end

    context "titleの幅が200以上のとき" do
      before{ @target.title = 'あ'*201 }
      it_should_behave_like "recent_entry_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:title].should_not be_blank
      end
    end

    context "contentの幅が5000以上のとき" do
      before{ @target.content = 'あ'*5001 }
      it_should_behave_like "recent_entry_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:content].should_not be_blank
      end
    end

    context "linkがhttpのスキーマではないとき" do
      before{ @target.link = 'ssh://foo.org/' }
      it_should_behave_like "recent_entry_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:link].should_not be_blank
      end
    end

    context "それら以外のとき" do
      before { @target = RecentEntry.make_unsaved }
  
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
