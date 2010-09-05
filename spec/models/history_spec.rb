# -*- encoding: utf-8 -*-
require 'spec_helper'

describe History do
  context "新規作成" do
    before do
      @target = (User.make.sites.first.histories<<History.make_unsaved).last
    end

    context "volume_levelが0から24以外のとき" do
      before{ @target.volume_level = 25 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:volume_level].should_not be_blank
      end
    end

    context "frequency_levelが0から24以外のとき" do
      before{ @target.frequency_level = 'alphabetマルチバイト' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:frequency_level].should_not be_blank
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
