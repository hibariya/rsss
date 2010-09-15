# -*- encoding: utf-8 -*-
require 'spec_helper'

describe User do
  before do
    @target = User.make_unsaved(:after_oauth)
  end
  
  context "新規作成" do
    context "screen_nameの幅が60以上のとき" do
      before{ @target.screen_name = 'a'*61 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:screen_name].should_not be_blank
      end
    end

    context "screen_nameが英数字とアンダースコア以外を含むとき" do
      before{ @target.screen_name = 'あばばば-ba' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:screen_name].should_not be_blank
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

    context "oauth_user_idがemptyなとき" do
      before{ @target.oauth_user_id = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:oauth_user_id].should_not be_blank
      end
    end

    context "oauth_user_idに数値以外が含まれているとき" do
      before{ @target.oauth_user_id = 'foo' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:oauth_user_id].should_not be_blank
      end
    end

    context "oauth_user_idの幅が100以上のとき" do
      before{ @target.oauth_user_id = '9'*101 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:oauth_user_id].should_not be_blank
      end
    end

    context "oauth_tokenがemptyなとき" do
      before{ @target.oauth_token = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:oauth_token].should_not be_blank
      end
    end

    context "oauth_tokenの幅が100以上のとき" do
      before{ @target.oauth_token = '9'*101 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:oauth_token].should_not be_blank
      end
    end

    context "oauth_secretがemptyなとき" do
      before{ @target.oauth_secret = '' }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:oauth_secret].should_not be_blank
      end
    end

    context "oauth_secretの幅が100以上のとき" do
      before{ @target.oauth_secret = '9'*101 }
      it "invalidになり、errorsにエラーメッセージが含まれている" do
        @target.should_not be_valid
        @target.errors[:oauth_secret].should_not be_blank
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
      before { @target = User.make_unsaved(:after_oauth) }

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
        @target = User.make_unsaved(:after_oauth)
        @target.description = ''
      end

      it "validationエラーにはならなない" do
        @target.should be_valid
      end
    end

    context "siteが空のとき" do
      before do
        @target = User.make_unsaved(:after_oauth)
        @target.site = ''
      end

      it "validationエラーにはならなない" do
        @target.should be_valid
      end
    end
  end
 
  describe ".find_by_token" do
    before do
      @target = User.make
    end

    it "tokenをもとにUserを取得できること" do
      User.find_by_token(@target.token).should be_kind_of User
    end
    
    it "存在しないtokenを渡された場合はnilを返すこと" do
      User.find_by_token('ababababababa').should be_nil
    end
  end

  describe "#summaries" do
    it "引数を与えない場合は最新のhistory一覧を返す" do
      @target.summaries.each do |history|
        expected = history.site.histories.sort_by(&:created_at)[-1]
        history._id.should == expected._id
      end
    end

    it "第1引数に数値を与えた場合は指定された数値分過去のhistory一覧を返す" do
      @target.summaries(2).each do |history|
        expected = history.site.histories.sort_by(&:created_at)[-3]
        history._id.should == expected._id
      end
    end

    it "戻り値はnilを含まない" do
      @target.sites.first.stub!(:histories).and_return([])
      @target.summaries.each do |history|
        history.should_not be_nil
      end
    end

  end

  describe "#create_histories" do
    before do
      @target.sites.map{|s| 
        s.histories = []
        s.stub!(:reload_channel).and_return(nil)
      }
    end

    it "同じ日のヒストリは2つ以上つくることができない" do
      2.times{ @target.create_histories }
      @target.sites.map do |site|
        site.histories.
          find_all{|h| h.created_at.strftime('%Y%m%d')==Time.now.strftime('%Y%m%d') }.
          length.should == 1
      end
    end

    it "何度呼び出しても30件以上のヒストリが登録されている状態にはならない" do
      pending('ねむい')
     #40.downto(0){|t| puts t.days.ago.to_time.inspect; @target.create_histories(t.days.ago.to_time) }
     #@target.sites.map do |site|
     #  site.histories.length.should == 30
     #end
    end

  end

  describe "reload_screen_name" do
    it "pending" do pending('pending') end
  end

end
