# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Rsss::Analyzable do
  class AnalyzableObject
    include Rsss::Analyzable
    attr_accessor :items
  end
  
  context "includeしたクラスは" do
    let(:target){ AnalyzableObject.new }

    before :all do
      target.items = ['foo', 'foofoo', 'hoge', 'piyo']
    end

    it "analyzeメソッドをレシーブでき、Rsss:Analyzer.analyzeの結果をHashで返する" do
      target.should be_respond_to :analyze
      target.analyze(:items, :length).should be_kind_of Hash
    end

    it "analyze_byメソッドをレシーブでき、Rsss:Analyzer.analyzeの結果をHashで返する" do
      target.should be_respond_to :analyze_by
      target.analyze_by(:items, :length).should be_kind_of Hash
    end

    it "長さは元の配列と等しい" do
      target.analyze_by(:items, :length).should have(target.items.length).items
    end

    it "要素はすべて24までの数値" do
      target.analyze_by(:items, :length).should be_all{|key, score| score <= 24 }
    end

    it "キーはすべて元の配列の要素で構成されている" do
      target.analyze_by(:items, :length).should be_all{|key, score| target.items.include? key }
    end
  end
end

