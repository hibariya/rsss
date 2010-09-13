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

  describe Site::EntryExtractor do
    shared_examples_for 'entry_extractor_extracting' do
      it "#title エントリのタイトルが取得できる" do
        @extractors.each{|e| e.title.should_not be_empty }
      end

      it "#content エントリのコンテンツが取得できる" do
        @extractors.each{|e| e.content.should_not be_empty }
      end

      it "#link パーマリンクが取得できる" do
        @extractors.each do |e|
          e.link.should_not be_nil
          e.link.should match(URI.regexp(['http']))
        end
      end

      it "#categories カテゴリ一覧が取得できる" do
        @extractors.each do |e|
          e.categories.should_not be_nil
          e.categories.should be_kind_of Array
        end
      end

      it "#date 日付が取得できる" do
        @extractors.each do |e|
          e.date.should_not be_nil
          e.link.should match(URI.regexp(['http']))
        end
      end

      it "#to_entry Entryに変換することができる" do
        @extractors.each do |e|
          e.to_entry.should be_kind_of Entry
        end
      end
    end

    context "RSS1.0フィード情報の抽出" do
      before do
        @feed = RSS::Parser.parse(Site::EntryExtractor.sample_feed('1.0'), false, true)
        @entries = (@feed.respond_to?(:entries)? @feed.entries: @feed.items)
        @extractors = @entries.map{|e| Site::EntryExtractor.new(e) }
      end
      it_should_behave_like 'entry_extractor_extracting'
    end

    context "RSS2.0フィード情報の抽出" do
      before do
        @feed = RSS::Parser.parse(Site::EntryExtractor.sample_feed('2.0'), false, true)
        @entries = (@feed.respond_to?(:entries)? @feed.entries: @feed.items)
        @extractors = @entries.map{|e| Site::EntryExtractor.new(e) }
      end
      it_should_behave_like 'entry_extractor_extracting'
    end

    context "atomフィード情報の抽出" do
      before do
        @feed = RSS::Parser.parse(Site::EntryExtractor.sample_feed('atom'), false, true)
        @entries = (@feed.respond_to?(:entries)? @feed.entries: @feed.items)
        @extractors = @entries.map{|e| Site::EntryExtractor.new(e) }
      end
      it_should_behave_like 'entry_extractor_extracting'
    end

  end
end
