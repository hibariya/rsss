# -*- encoding: utf-8 -*-

module Rsss::Analyzable

  def analyze(list_sym=:items, greatness_method=:greatness, step=24)
    items = __send__(list_sym).map do |item|
      [item, item.__send__(greatness_method).to_f]
    end
    results = Hash[*Rsss::Analyzer.analyze(items, step).flatten]

    if block_given?
      results.each{|item, score| yield item, score }
    end
    results
  end
  alias analyze_by analyze

end
