# -*- encoding: utf-8 -*-

require 'spec_helper'

describe User do
  describe '#save' do
    before :all do
      @target = Fabricate.build(:authorized_user)
    end

    context "screen_nameの幅が60以上のとき" do
      before{ @target.auth_profile.screen_name = 'a'*61 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:screen_name].should_not be_blank
      end
    end

    context "screen_nameが英数字とアンダースコア以外を含むとき" do
      before{ @target.auth_profile.screen_name = 'あばばば-ba' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:screen_name].should_not be_blank
      end
    end

    context "descriptionの幅が200を超えるとき" do
      before{ @target.description = 'ば'*201 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:description].should_not be_blank
      end
    end

    context "siteがhttpから始まらないとき" do
      before{ @target.site = 'ftp://hoge.com/piyo' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:site].should_not be_blank
      end
    end

    context "siteの幅が400以上のとき" do
      before{ @target.site = 'http://hoga.com/'+('a'*400) }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:site].should_not be_blank
      end
    end

    context "auth_profile.user_idがemptyなとき" do
      before{ @target.auth_profile.user_id = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:user_id].should_not be_blank
      end
    end

    context "auth_profile.user_idに数値以外が含まれているとき" do
      before{ @target.auth_profile.user_id = 'foo' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:user_id].should_not be_blank
      end
    end

    context "auth_profile.user_idの幅が100以上のとき" do
      before{ @target.auth_profile.user_id = '9'*101 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:user_id].should_not be_blank
      end
    end

    context "auth_profile.tokenがemptyなとき" do
      before{ @target.auth_profile.token = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:token].should_not be_blank
      end
    end

    context "auth_profile.tokenの幅が100以上のとき" do
      before{ @target.auth_profile.token = '9'*101 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:token].should_not be_blank
      end
    end

    context "auth_profile.secretがemptyなとき" do
      before{ @target.auth_profile.secret = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:secret].should_not be_blank
      end
    end

    context "auth_profile.secretの幅が100以上のとき" do
      before{ @target.auth_profile.secret = '9'*101 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:auth_profile].should_not be_blank
        @target.auth_profile.errors[:secret].should_not be_blank
      end
    end

    context "tokenの幅が100以上のとき" do
      before{ @target.token = '9'*101 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:token].should_not be_blank
      end
    end

    context "それら意外のとき" do
      before { @target = Fabricate.build(:authorized_user) }

      it "validationエラーにはならなない" do
        @target.should be_valid
        @target.errors.length.should==0
      end

      it "保存できる" do
        @target.save.should be_true
      end
    end

    context "descriptionが空のとき" do
      before do
        @target = Fabricate.build(:authorized_user)
        @target.description = ''
      end

      it "validationエラーにはならない" do
        @target.should be_valid
      end
    end

    context "siteが空のとき" do
      before do
        @target = Fabricate.build(:authorized_user)
        @target.site = ''
      end

      it "validationエラーにはならない" do
        @target.should be_valid
      end
    end

  end

end

