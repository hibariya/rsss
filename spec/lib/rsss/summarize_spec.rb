# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Rsss::Summarize do
  describe ".new" do
    before do
      # 予め計算しておいた値
      @sites = [
        {:site=>Fabricate.build(:site),
         :input=>{:volume=>10.0, :frequency=>0.5},
         :expect=>{:volume_level=>15, :frequency_level=>14},
         :got=>{}},
        {:site=>Fabricate.build(:site),
         :input=>{:volume=>15.0, :frequency=>0.75},
         :expect=>{:volume_level=>24, :frequency_level=>24},
         :got=>{}},
        {:site=>Fabricate.build(:site),
         :input=>{:volume=>5.0, :frequency=>0.25},
         :expect=>{:volume_level=>3, :frequency_level=>0},
         :got=>{}}
      ]
      @user = Fabricate.build(:user, :sites=>@sites.map{|site|
        site[:site].stub!(:volume).and_return(site[:input][:volume])
        site[:site].stub!(:frequency).and_return(site[:input][:frequency])
        site[:site]
      })
      @target = Rsss::Summarize.new(@user.sites)
    end
    
    it "戻り値はRsss::Summarizeであること" do
      @target.should be_kind_of Rsss::Summarize
    end
    
    it "存在しないメソッド呼び出しは@summariesに委譲される" do
      @target.length.should == 3
    end
    
    it "volume_level, frequency_levelが算出されている" do
      @target.each do |site, result|
        expect = @sites.find{|s| s[:site]==site }[:expect]
        result[:volume_level].should == expect[:volume_level]
        result[:frequency_level].should == expect[:frequency_level]
      end
    end
  end

  context ".segment メソッドを呼び出したとき" do
    before do
      @sites = [
        {:site=>'sitea',
         :input=>{:volume=>10.0, :frequency=>0.5},
         :expect=>{:volume_level=>15, :frequency_level=>14},
         :got=>{}},
        {:site=>'siteb',
         :input=>{:volume=>15.0, :frequency=>0.75},
         :expect=>{:volume_level=>24, :frequency_level=>24},
         :got=>{}},
        {:site=>'sitec',
         :input=>{:volume=>5.0, :frequency=>0.25},
         :expect=>{:volume_level=>3, :frequency_level=>0},
         :got=>{}}
      ]
    end

    it "volumeを相対評価して25段階の妥当なスコアを算出できる" do
      Rsss::Summarize.segment(@sites.map{|site| [site[:site], site[:input][:volume]] }).each do |got|
        site = @sites.find{|s| s[:site]==got.first }
        got.last.should == site[:expect][:volume_level]
      end
    end

    it "frequencyを相対評価して25段階の妥当なスコアを算出できる" do
      Rsss::Summarize.segment(@sites.map{|site| [site[:site], site[:input][:frequency]] }).each do |got|
        site = @sites.find{|s| s[:site]==got.first }
        got.last.should == site[:expect][:frequency_level]
      end
    end

    context "すべてのサイトのエントリが0のとき" do
      before do
        @sites = [
          {:site=>'sitea',
            :input=>{:volume=>0.0, :frequency=>0.0},
            :expect=>{:volume_level=>0, :frequency_level=>0},
            :got=>{}},
          {:site=>'siteb',
            :input=>{:volume=>0.0, :frequency=>0.0},
            :expect=>{:volume_level=>0, :frequency_level=>0},
            :got=>{}},
          {:site=>'sitec',
            :input=>{:volume=>0.0, :frequency=>0.0},
            :expect=>{:volume_level=>0, :frequency_level=>0},
            :got=>{}}
        ]
      end

      it "volumeを相対評価したときすべてのスコアは0になる" do
        Rsss::Summarize.segment(@sites.map{|site| [site[:site], site[:input][:volume]] }).each do |got|
          got.last.should == 0
        end
      end

      it "frequencyを相対評価したときすべてのスコアは0になる" do
        Rsss::Summarize.segment(@sites.map{|site| [site[:site], site[:input][:frequency]] }).each do |got|
          got.last.should == 0
        end
      end
    end

    context "すべてのサイトのエントリが同じ量/頻度のとき" do
      before do
        @sites = [
          {:site=>'sitea',
            :input=>{:volume=>10, :frequency=>1.0},
            :expect=>{:volume_level=>24, :frequency_level=>24},
            :got=>{}},
          {:site=>'siteb',
            :input=>{:volume=>10, :frequency=>1.0},
            :expect=>{:volume_level=>24, :frequency_level=>24},
            :got=>{}},
          {:site=>'sitec',
            :input=>{:volume=>10, :frequency=>1.0},
            :expect=>{:volume_level=>24, :frequency_level=>24},
            :got=>{}}
        ]
      end

      it "volumeを相対評価したときすべてのスコアは24になる" do
        Rsss::Summarize.segment(@sites.map{|site| [site[:site], site[:input][:volume]] }).each do |got|
          got.last.should == 24
        end
      end

      it "frequencyを相対評価したときすべてのスコアは24になる" do
        Rsss::Summarize.segment(@sites.map{|site| [site[:site], site[:input][:frequency]] }).each do |got|
          got.last.should == 24
        end
      end
    end
  end

end
