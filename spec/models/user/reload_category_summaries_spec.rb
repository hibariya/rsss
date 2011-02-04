# -*- encoding: utf-8 -*-

require 'spec_helper'

describe 'User#reload_category_summary' do
  let!(:user) do
    user = Fabricate :user
    user.reload_categories
    user
  end

  let!(:frequency_scores){ user.analyze_by :categories, :frequency }

  before :all do
    user.category_summaries.map &:destroy
    user.reload_category_summaries
  end

  it "カテゴリの数と同じだけsummaryが保存されていること" do
    user.category_summaries.length.should eql user.categories.length
  end

  it "日付が登録されていること" do
    user.category_summaries.should be_all &:date
  end

  it "更新されたsummaryが保存されていること" do
    user.categories.each do |cat|
      last_summary = user.category_summaries.select{|c| c.category_id == cat.id }.last
      last_summary.frequency_score.should == frequency_scores[cat]
    end
  end


end

