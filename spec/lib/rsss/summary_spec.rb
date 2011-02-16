# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Rsss::Summary, :clear => true do
  class Color
    include Mongoid::Document
    field :content, :type => String
  end

  class Area
    include Mongoid::Document
    embeds_many :color_summaries
    field :mayor, :type => String
  end

  class ColorSummary
    include Mongoid::Document
    include Rsss::Summary
    embedded_in :areas, :inverse_of => :color_summaries

    field :color_id, :type => BSON::ObjectId
    field :score,    :type => Fixnum
    max_documents 30
  end

  let!(:color){ Color.create! :content => 'foo' }
  let!(:area) do
    Area.create! :mayor => 'w00t!',
      :color_summaries => [ColorSummary.new(:color_id => color.id, :score => 5, :date => 30.days.ago)]
  end
  let!(:color_summary){ area.color_summaries.first }

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
      29.downto(1).map do |t|
        area.color_summaries<< ColorSummary.new(:color_id => color.id, :score => t, :date => t.days.ago.to_date)
        area.save
      end
    end

    it "新たなドキュメントを保存したときには最も古いドキュメントが削除される" do
      area.color_summaries<< ColorSummary.new(:color_id => color.id, :score => 1)
      area.save
      area.color_summaries.should_not be_any {|cs| cs == color_summary }
    end
  end

  context "同じ日にドキュメントを作成すると古い方が削除される" do
    let!(:today) do
      area.color_summaries<< ColorSummary.new(:color_id => color.id, :score => 0)
      area.save
      area.color_summaries.last
    end

    it "新たなドキュメントを保存したときには最も古いドキュメントが削除される" do
      today.date.should eql Date.today

      area.color_summaries<< ColorSummary.new(:color_id => color.id, :score => 100)
      area.save

      area.color_summaries.should_not be_all {|cs| cs == today }
      area.color_summaries.should_not be_any {|cs| cs == today }
    end
  end

end

