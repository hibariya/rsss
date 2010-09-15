# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Rsss::Rss do
  describe ".get" do
    it "pending" do pending('pending') end
  end

  describe Rsss::Rss::Entry do
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
        @feed = RSS::Parser.parse(Rsss::Rss.sample_feed('1.0'), false, true)
        @entries = (@feed.respond_to?(:entries)? @feed.entries: @feed.items)
        @extractors = @entries.map{|e| Rsss::Rss::Entry.extract(e) }
      end
      it_should_behave_like 'entry_extractor_extracting'
    end
    
    context "RSS2.0フィード情報の抽出" do
      before do
        @feed = RSS::Parser.parse(Rsss::Rss.sample_feed('2.0'), false, true)
        @entries = (@feed.respond_to?(:entries)? @feed.entries: @feed.items)
        @extractors = @entries.map{|e| Rsss::Rss::Entry.extract(e) }
      end
      it_should_behave_like 'entry_extractor_extracting'
    end
    
    context "atomフィード情報の抽出" do
      before do
        @feed = RSS::Parser.parse(Rsss::Rss.sample_feed('atom'), false, true)
        @entries = (@feed.respond_to?(:entries)? @feed.entries: @feed.items)
        @extractors = @entries.map{|e| Rsss::Rss::Entry.extract(e) }
      end
      it_should_behave_like 'entry_extractor_extracting'
    end

  end
end
