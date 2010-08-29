# -*- encoding: utf-8 -*-
require 'spec_helper'

describe User do
  context "新規作成" do
    before(:each) do
      @target = User.make_unsaved(:after_oauth)
    end

    shared_examples_for "user_invalid_record" do
      it "invalidとなり保存できない" do
        @target.should_not be_valid
        @target.save.should be_false
      end
    end

    context "screen_nameの幅が60以上のとき" do
      before{ @target.screen_name = 'a'*61 }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:screen_name].should_not be_blank
      end
    end

    context "screen_nameが英数字とアンダースコア以外を含むとき" do
      before{ @target.screen_name = 'あばばば-ba' }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:screen_name].should_not be_blank
      end
    end

    context "descriptionの幅が200を超えるとき" do
      before{ @target.description = 'ば'*201 }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:description].should_not be_blank
      end
    end

    context "siteがHTTPのURLスキーマから始まらないとき" do
      before{ @target.site = 'ftp://hoge.com/piyo' }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:site].should_not be_blank
      end
    end

    context "siteの幅が400以上のとき" do
      before{ @target.site = 'http://hoga.com/'+('a'*400) }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:site].should_not be_blank
      end
    end

    context "oauth_user_idがemptyなとき" do
      before{ @target.oauth_user_id = '' }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:oauth_user_id].should_not be_blank
      end
    end

    context "oauth_user_idに数値以外が含まれているとき" do
      before{ @target.oauth_user_id = 'foo' }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:oauth_user_id].should_not be_blank
      end
    end

    context "oauth_user_idの幅が100以上のとき" do
      before{ @target.oauth_user_id = '9'*101 }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:oauth_user_id].should_not be_blank
      end
    end

    context "oauth_tokenがemptyなとき" do
      before{ @target.oauth_token = '' }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:oauth_token].should_not be_blank
      end
    end

    context "oauth_tokenの幅が100以上のとき" do
      before{ @target.oauth_token = '9'*101 }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:oauth_token].should_not be_blank
      end
    end

    context "oauth_secretがemptyなとき" do
      before{ @target.oauth_secret = '' }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:oauth_secret].should_not be_blank
      end
    end

    context "oauth_secretの幅が100以上のとき" do
      before{ @target.oauth_secret = '9'*101 }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:oauth_secret].should_not be_blank
      end
    end

    context "tokenの幅が100以上のとき" do
      before{ @target.token = '9'*101 }
      it_should_behave_like "user_invalid_record"
      it "errorsにエラーメッセージが含まれている" do
        @target.errors[:token].should_not be_blank
      end
    end

    context "それら意外のとき" do
      before { @target = User.make_unsaved(:after_oauth) }

      it "validationエラーにはならなない" do
        @target.should be_valid
        @target.errors.length.should==0
      end
       
      it "保存できる" do
        @target.save.should be_true
      end
    end

  end
end
