# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Rsss::Analyzer do
  let(:step){ 24 }
  let(:all_zero){ 10.times.map{|t| ["zero#{t}", 0.0] } }
  let(:all_flat){ 20.times.map{|t| ["flat#{t}", 3.14] } }
  let(:step_items){ 5.times.map{|t| ["step#{t}", t.to_f] } }
  let(:random_items){ %w(1 32 4 8 5 9 2).each_with_index.map{|v,t| ["rand#{t}", v.to_f] } }
  let(:duplicate_included_items){ random_items + all_zero + step_items + all_flat }
  let(:expected_order){ step_items.sort_by(&:last).map(&:first) }

  context "すべての値がゼロの場合" do
    subject{ Rsss::Analyzer.analyze all_zero }

    it "すべてのスコアはゼロになる" do
      subject.each{|item, score| score.should be_zero }
    end

    shared_examples_for "すべてのスコアに共通の振舞" do
      it "Fixnumであること" do
        subject.each{|item, score| score.should be_kind_of Fixnum }
      end
    end
    
    it_should_behave_like "すべてのスコアに共通の振舞"
  end

  context "すべての値が同じ値の場合" do
    subject{ Rsss::Analyzer.analyze all_flat, step }

    it "すべてのスコアは最高値になる" do
      subject.each{|item, score| score.should eql (step-1) }
    end

    it_should_behave_like "すべてのスコアに共通の振舞"
  end

  context "すべての値がばらばらな場合" do
    subject{ Rsss::Analyzer.analyze step_items, step }

    it "相応しい相対値がスコアになる" do
      key = 0
      subject.sort_by(&:last).each do |item, score|
        item.should == expected_order[key]
        key += 1
      end
    end

    it_should_behave_like "すべてのスコアに共通の振舞"
  end

  context "値がばらばらだったり同じだったり色々な場合" do
    subject{ Rsss::Analyzer.analyze step_items, step }

    it "相応しい相対値がスコアになる" do
      key = 0
      subject.sort_by(&:last).each do |item, score|
        item.should == expected_order[key]
        key += 1
      end
    end

    it_should_behave_like "すべてのスコアに共通の振舞"
  end

end
