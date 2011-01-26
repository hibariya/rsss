# -*- encoding: utf-8 -*-

require 'spec_helper'

describe Site do
  before :all do
    @now = Time.now
    @user = Fabricate(:user)
    @site = @user.sites.first
    @entries = @site.entries.sort_by(&:date)
    @contents = [@entries.map(&:title), @entries.map(&:content)].flatten.join.gsub(/<\/?[^>]+>|\s/, '')
  end

  describe "#frequency" do
    subject do
      stub(Time).now{ @now }
      @seconds = @now.to_i - @entries.first.date.to_i
      @site.frequency
    end

    it "サイトの更新頻度" do
      should == @entries.length/(@seconds.to_f/86400.0)
    end
  end

  describe "frequency(未来の日付が入っている場合)" do
    subject do
      stub(Time).now{ @now }
      @entries.last.date = 1.day.since
      @seconds = @now.to_i - @entries.first.date.to_i
      @site.frequency
    end

    it "サイトの更新頻度は影響を受けない" do
      should == @entries.length/(@seconds.to_f/86400.0)
    end
  end

  describe "frequency(過去の日付が最新の場合)" do
    subject do
      stub(Time).now{ @now }
      @entries.last.date = 1.day.ago
      @seconds = @now.to_i - @entries.first.date.to_i
      @site.frequency
    end

    it "サイトの更新頻度には常に現在が使用される" do
      should == @entries.length/(@seconds.to_f/86400.0)
    end
  end

  describe "volume" do
    subject do
      stub(Time).now{ @now }
      @seconds = @now.to_i - @entries.first.date.to_i
      @site.volume
    end

    it "サイトの更新バイト数" do
      should == @contents.length.to_f/(@seconds.to_f/86400.0)
    end
  end

  describe "volume(未来の日付が入っている場合)" do
    subject do
      stub(Time).now{ @now }
      @entries.last.date = 1.day.since
      @seconds = @now.to_i - @entries.first.date.to_i
      @site.volume
    end

    it "サイトの更新バイト数は影響を受けない" do
      should == @contents.length/(@seconds.to_f/86400.0)
    end
  end

  describe "volume(過去の日付が最新の場合)" do
    subject do
      stub(Time).now{ @now }
      @entries.last.date = 1.day.ago
      @seconds = @now.to_i - @entries.first.date.to_i
      @site.volume
    end

    it "サイトの更新バイト数は常に現在を使用する" do
      should == @contents.length/(@seconds.to_f/86400.0)
    end
  end


end

