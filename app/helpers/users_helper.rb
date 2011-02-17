# -*- encoding: utf-8 -*-
module UsersHelper
  def upbeat_or_downbeat(site)
    return '⇧' if site.upbeat?
    return '⇩' if site.downbeat?
  end


  def color_codes
    %w(#f39700 #e60012 #9caeb7 #00a7db #009944 #d7c447 #9b7cb6 #00ada9
       #bb641d #e85298 #0079c2 #6cbb5a #b6007a #e5171f #522886 #0078ba
       #019a66 #e44d93 #814721 #a9cc51 #ee7b1a #00a0de)
  end

  def graph_data_codes(sites)
    sites.map do |site| 
      history = Array.new 30, 0
      site.summaries.each_with_index{|s,i| history[i] = s.score }
      "g.data('#{site.domain}', #{history[0...30].inspect});"
    end.join("\n")
  end

  def score(s)
    ((s.to_f/24)*100).round
  end

end

