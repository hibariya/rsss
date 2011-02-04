# -*- encoding: utf-8 -*-

require 'spec_helper'

describe 'User#reload_site_summaries', :clear => true do
  let!(:user){ Fabricate :user }
  let!(:volume_scores){ user.analyze_by :sites, :volume }
  let!(:frequency_scores){ user.analyze_by :sites, :frequency }

  before :all do
    user.site_summaries.map &:destroy
    user.reload_site_summaries
  end

  it "サイトの数と同じだけsummaryが保存されていること" do
    user.site_summaries.length.should eql user.sites.length
  end

  it "日付が登録されていること" do
    user.site_summaries.should be_all &:date
  end

  it "更新されたsummaryが保存されていること" do
    user.sites.each do |site|
      last_summary = user.site_summaries.select{|s| s.site_id == site.id }.last
      last_summary.volume_score.should    eql volume_scores[site]
      last_summary.frequency_score.should eql frequency_scores[site]
    end
  end

end

