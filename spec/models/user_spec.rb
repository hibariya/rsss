# -*- encoding: utf-8 -*-
require 'spec_helper'

describe User do
  context "新規作成" do
    before do
      @target = User.make_unsaved(:after_oauth)
    end

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
  
  describe "#create_histories" do
  end

  describe User::SnapShot do
    context ".take メソッドを呼び出したとき" do
      before do
        # 予め計算しておいた値
        @sites = [
          {:site=>Site.make_unsaved,
           :volume=>10.0,
           :frequency=>0.5,
           :volume_level=>15,
           :frequency_level=>14},
          {:site=>Site.make_unsaved,
           :volume=>15.0,
           :frequency=>0.75,
           :volume_level=>24,
           :frequency_level=>24},
          {:site=>Site.make_unsaved,
           :volume=>5.0,
           :frequency=>0.25,
           :volume_level=>3,
           :frequency_level=>0}
        ]
        @target = User.make_unsaved(:sites=>@sites.map{|s|
          site = s[:site]
          site.stub!(:volume).and_return(s[:volume])
          site.stub!(:frequency).and_return(s[:frequency])
          site
        })
      end

      it "値を相対評価して25段階のスコアを算出する" do
        User::SnapShot.take(@target).sites.each do |s| 
          site = @sites.find{|f| f[:site]._id==s._id }
          s.history(0).volume_level.should == site[:volume_level]
          s.history(0).frequency_level.should == site[:frequency_level]
        end
      end


      context "すべてのサイトのエントリが0のとき" do
        before do
          @target = User.make_unsaved(:sites=>3.times.map{
            site=Site.make_unsaved
            site.stub!(:volume).and_return(0)
            site.stub!(:frequency).and_return(0.0)
            site
          })
        end

        it "すべてのスコアが0になる" do
          User::SnapShot.take(@target).sites.each do |s| 
            s.history(0).volume_level.should == 0
            s.history(0).frequency_level.should == 0
            s.history(0).general_level.should == 0
          end
        end
      end

      context "すべてのサイトのエントリが同じ量/頻度のとき" do
        before do
          @target = User.make_unsaved(:sites=>3.times.map{
            site=Site.make_unsaved
            site.stub!(:volume).and_return(10)
            site.stub!(:frequency).and_return(10.0)
            site
          })
        end

        it "すべてのスコアが24になる" do
          User::SnapShot.take(@target).sites.each do |s| 
            s.history(0).volume_level.should == 24
            s.history(0).frequency_level.should == 24
          end
        end
      end
    end



  end
end
