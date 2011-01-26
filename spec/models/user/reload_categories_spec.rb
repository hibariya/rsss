# -*- encoding: utf-8 -*-

require 'spec_helper'

describe 'User#reload_categories' do
  let!(:target){ Fabricate :user }
  let!(:categories){ target.sites.map(&:categories).flatten }

  before :all do
    target.reload_categories
  end

  it "各エントリに登録されているカテゴリがもれなく登録されていること" do
    categories.uniq.each do |category|
      target.categories.where(:name=>category).should_not be_empty
    end
  end

  it "各カテゴリの出現回数が正しく更新されている" do
    categories.inject({}){|r,c| r[c] ||= 0; r[c]+=1; r }.each do |category, len|
      target.categories.where(:name=>category).first.frequency.should eql len.to_f
    end
  end

end

