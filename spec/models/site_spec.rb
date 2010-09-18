# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Site do
  context "新規作成" do
    before do
      @target = (User.make.sites<<Site.make_unsaved).last
    end

    context "uriがhttpから始まらないとき" do
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

    context "titleの幅が200を超えるとき" do
      before{ @target.title = 'あ'*201 }
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

  describe "#unique?" do
    context "そのユーザが既に重複するURIを登録しているとき" do
      before do
        @target = User.make
        @target.sites<<Site.make
        @target.sites<<Site.make(:uri=>@target.sites.last.uri)
      end
      
      it "falseを返す" do
        @target.sites.last.unique?.should be_false
      end
    end

    context "そのユーザが初めて登録するURIのとき" do
      before do
        @target = User.make
        @target.sites<<Site.make(:uri=>'http://hibariya.org/rss')
      end
      
      it "trueを返す" do
        @target.sites.last.unique?.should be_true
      end
    end
  end
  
  describe "#history" do
    before do
      user = User.make(:sites=>[])
      user.sites<<Site.make(:histories=>[])
      @target = user.sites.last
      10.times{|t| @target.histories<<History.make(:created_at=>t.days.ago.to_time) }
    end

    context "引数なしで呼び出したとき" do
      it "一番新しいHistroryを返す" do
        @target.history.created_at.strftime('%Y%m%d')==0.days.ago.strftime('%Y%m%d')
      end
    end

    context "第一引数に数値numを渡したとき" do
      it "num番目に新しいHistoryを返す" do
        10.times{|t| @target.history(t).created_at.strftime('%Y%m%d')==t.days.ago.strftime('%Y%m%d') }
      end
    end

    context "第一引数に存在しない数値numを渡したとき" do
      it "空のHistoryインスタンスを返す" do
        @target.history(1000).should be_kind_of History
        @target.history(1000).should be_new_record
      end
    end
  end

  describe "#reload_channel_info" do
    before do
      @expecteds = {:title=> 'Example', :site_uri=>'http://example.com/'}
      @target = User.make(:sites=>[Site.make])
      @target.sites.first.stub!(:feed).
        and_return(RSS::Parser.parse(Rsss::Rss.sample_feed('1.0')))
      @target.sites.first.load_channel_info
    end

    it "取得した新しいフィードの情報をロードする" do
      @target.sites.first.title.should == @expecteds[:title]
      @target.sites.first.site_uri.should == @expecteds[:site_uri]
    end

    it "ただし、保存はされない" do
      @target.reload.sites.first.title.should_not == @expecteds[:title]
      @target.reload.sites.first.site_uri.should_not == @expecteds[:site_uri]
    end
  end

  describe "#reload_channel_info!" do
    before do
      @expecteds = {:title=> 'Example', :site_uri=>'http://example.com/'}
      @target = User.make(:sites=>[Site.make])
      @target.sites.first.stub!(:feed).
        and_return(RSS::Parser.parse(Rsss::Rss.sample_feed('1.0')))
      @target.sites.first.load_channel_info!
    end

    it "取得した新しいフィードの情報をロードする" do
      @target.sites.first.title.should == @expecteds[:title]
      @target.sites.first.site_uri.should == @expecteds[:site_uri]
    end

    it "保存されている" do
      @target.reload.sites.first.title.should == @expecteds[:title]
      @target.reload.sites.first.site_uri.should == @expecteds[:site_uri]
    end
  end

  describe "#reload_channel" do
    before do
      @target_rss = RSS::Parser.parse(Rsss::Rss.sample_feed('2.0'))
      @target = User.make(:sites=>[Site.make])
      @target.sites.first.stub!(:feed).and_return(@target_rss)
      @target.sites.first.reload_channel
    end

    it "保持しているエントリ一覧を最新のエントリ一覧で上書きする" do
      @target_rss.items.each_with_index do |item, i|
        @target.sites.first.entries[i].title.should == item.title
        @target.sites.first.entries[i].link.should == item.link
      end
    end
    
    it "ただし、保存はしない" do
      @target.reload
      @target_rss.items.each_with_index do |item, i|
        @target.sites.first.entries[i].title.should_not == item.title
        @target.sites.first.entries[i].link.should_not == item.link
      end
    end
  end

  describe "#reload_channel!" do
    before do
      @target_rss = RSS::Parser.parse(Rsss::Rss.sample_feed('2.0'))
      @target = User.make(:sites=>[Site.make])
      @target.sites.first.stub!(:feed).and_return(@target_rss)
      @target.sites.first.reload_channel!
    end

    it "保持しているエントリ一覧を最新のエントリ一覧で上書きする" do
      @target_rss.items.each_with_index do |item, i|
        @target.sites.first.entries[i].title.should == item.title
        @target.sites.first.entries[i].link.should == item.link
      end
    end
    
    it "保存もされている" do
      @target.reload
      @target_rss.items.each_with_index do |item, i|
        @target.sites.first.entries[i].title.should == item.title
        @target.sites.first.entries[i].link.should == item.link
      end
    end
  end

  describe "#time_length" do
    before do
      @target = Site.make(:histories=>[], :entries=>[])
      30.times{|t| @target.entries<<Entry.make(:date=>t.days.ago.to_time) }
    end

    context "Constantな(15日以上ブランクがない)投稿が行われている場合" do
      before do
        Time.stub!(:now).and_return(Time.now)
      end

      it "現在のUnixTimeから一番古いEntryのUnixTimeを引いた値になる" do
        @target.time_length.should == Time.now.to_i-@target.entries.last.date.to_time.to_i
      end
    end

    context "15日以上ブランクがある場合" do
      before do
        @target.entries<<Entry.make(:date=>60.days.ago.to_time)
        Time.stub!(:now).and_return(Time.now)
      end

      it "ブランクは15日として扱われ、15日以上のブランクは無視される" do
        @target.time_length.should_not == Time.now.to_i-@target.entries.last.date.to_time.to_i
        @target.time_length.should == Time.now.to_i-(@target.entries.last.date.to_time.to_i+(16*86400))
      end
    end
  end

  describe "#day_length" do
    before do
      @target = Site.make(:histories=>[], :entries=>[])
      30.times{|t| @target.entries<<Entry.make(:date=>t.days.ago.to_time) }
      Time.stub!(:now).and_return(Time.now)
    end

    it "time_lengthを浮動小数点の日数で返す" do
      @target.day_length.should == @target.time_length.to_f/86400
    end
  end

  describe "#count_daily" do
    before do
      @target = Site.make(:histories=>[], :entries=>[])
      30.times{|t| @target.entries<<Entry.make(:date=>t.days.ago.to_time) }
      Time.stub!(:now).and_return(Time.now)
    end

    it "与えられた数値を総数として、1日あたりの数を返す" do
      @target.count_daily(1000).should == 1000.to_f/@target.day_length
    end
  end

  describe "#volume" do
    before do
      @target = Site.make
    end

    it "全てのEntryのtitleとcontentを元に、1日あたりのバイト数を返す" do
      @target.volume.should == @target.entries.map{|e|e.title+e.content}.
        join.length.to_f/@target.day_length
    end
  end

  describe "#frequency" do
    before do
      @target = Site.make
    end

    it "Entryの数を元に、1日あたりのバイト数を返す" do
      @target.frequency.should == @target.entries.length.to_f/@target.day_length
    end
  end

  describe "#byte_length" do
    before do
      @target = Site.make
    end

    it "全てのEntryのtitleとcontentを連結した結果のバイト数を返す" do
      @target.byte_length.should == @target.entries.map{|e|e.title+e.content}.join.length
    end
  end

  describe "#length" do
    before do
      @target = Site.make
    end

    it "全てのEntryの数を返す" do
      @target.length.should == @target.entries.length
    end
  end

end
