# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Rsss::Summary, :clear => true do
  class Color
    include Mongoid::Document
    field :name, :type => String
  end

  class ColorSummary
    include Mongoid::Document
    include Rsss::Summary
    field :color_id, :type => BSON::ObjectId
    field :score,    :type => Fixnum
    max_documents 30
  end

  let!(:color){ Color.create! :content => 'foo' }
  let!(:color_summary){ ColorSummary.create! :color_id => color.id, :score => 5, :date => 30.days.ago }

  describe "includeしたクラス" do
    it "#references_key で参照モデルのキー名を取得できる" do
      ColorSummary.references_key.should eql :color_id
    end

    it "#references_name で参照モデルのモデル名を取得できる" do
      ColorSummary.references_name.should eql 'Color' 
    end

    it "#references で参照モデルのモデルクラスを取得できる" do
      ColorSummary.references.should eql Color 
    end

    it "#max_documents で保存できる最大のドキュメント数が取得できる" do
      ColorSummary.max_documents.should eql 30
    end
  end

  describe "includeしたクラスのインスタンス" do
    it "#references_key で参照モデルのキー名を取得できる" do
      color_summary.references_key.should eql :color_id
    end

    it "#[元モデル名] で参照モデルのインスタンスを取得できる" do
      color_summary.color.should eql color
    end

    it "#references で参照モデルのインスタンスを取得できる" do
      color_summary.references.should eql color
    end
  end

  context "ドキュメント数がmax_documentsに達したとき" do
    before :all do
      color_summaries = [color_summary]
      color_summaries += 29.downto(1).map do |t|
        ColorSummary.create :color_id => color.id,
                            :score    => t,
                            :date     => t.days.ago.to_date
      end
    end

    it "新たなドキュメントを保存したときには最も古いドキュメントが削除される" do
      ColorSummary.create! :color_id => color.id, :score => 1
      ColorSummary.all.should_not be_any {|cs| cs == color_summary }
    end
  end

  context "同じ日にドキュメントを作成すると古い方が削除される" do
    let!(:todays_summary){ ColorSummary.create :color_id => color.id, :score => 0 }

    it "新たなドキュメントを保存したときには最も古いドキュメントが削除される" do
      todays_summary.date.should eql Date.today
      ColorSummary.create :color_id => color.id, :score => 100
      ColorSummary.all.should_not be_any {|cs| cs == todays_summary }
    end
  end

end

