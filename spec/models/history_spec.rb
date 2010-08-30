# -*- encoding: utf-8 -*-
require 'spec_helper'

describe History do
  context "新規作成" do
    before(:each) do
      @target = History.make_unsaved
    end

    shared_examples_for "history_invalid_record" do
      it "invalidになること" do
        @target.should_not be_valid
      end
    end

    context "volume_levelが0から24以外のとき" do
      before{ @target.volume_level = 25 }
      it_should_behave_like "history_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:volume_level].should_not be_blank
      end
    end

    context "frequency_levelが0から24以外のとき" do
      before{ @target.frequency_level = 'alphabetマルチバイト' }
      it_should_behave_like "history_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:frequency_level].should_not be_blank
      end
    end

    context "それら以外のとき" do
      before { @target = History.make_unsaved }
      
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
