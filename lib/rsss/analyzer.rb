# -*- encoding: utf-8 -*-

module Rsss::Analyzer
  extend self

  # itemsから各itemの相対スコアを算出
  def analyze(items, step=24)

    if items.map(&:last).all?{|greatness| greatness==0.0 }
      # すべて0.0
      return analyze_all_zero items

    elsif items.map(&:last).uniq.length==1
      # すべて同じ値
      return analyze_all_flat items
    end

    min, max, factor = min_max_and_factor(items, step)
    items.map do |item|
      current = Math.sqrt(item.last)
      result = (current - min) * factor
      [item.first, result.round]
    end
  end

  def min_max_and_factor(items, step)
    greatnesses = items.map(&:last)
    min = Math.sqrt greatnesses.min
    max = Math.sqrt greatnesses.max
    [min, max, step/(max-min)]
  end

  def analyze_all_zero(items)
    items.map{|item| [item.first, 0] }
  end

  def analyze_all_flat(items, step=24)
    items.map{|item| [item.first, step-1] }
  end
end
