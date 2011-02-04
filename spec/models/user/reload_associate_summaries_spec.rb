# -*- encoding: utf-8 -*-

require 'spec_helper'

describe 'User#reload_associate_summary', :clear => true do
  let!(:target){ Fabricate :user }

  before :all do
    10.times.map{ Fabricate :user }.each do |user|
      user.reload_categories
      user.save
    end

    target.reload_associates
    @scores = target.analyze_by :associates, :score
    target.associate_summaries.map &:destroy
    target.reload_associate_summaries
    target.save
  end

  it "カテゴリの数と同じだけsummaryが保存されていること" do
    target.associate_summaries.length.should eql target.associates.length
  end

  it "日付が登録されていること" do
    target.associate_summaries.should be_all &:date
  end

  it "更新されたsummaryが保存されていること" do
    target.associates.each do |asc|
      last_summary = target.associate_summaries.select{|a| a.associate_id == asc.id }.last
      last_summary.score.should == @scores[asc]
    end
  end

end

