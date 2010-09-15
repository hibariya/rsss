module Rsss
  class Summarize
    class << self
      #
      # 24点満点の相対評価を行う
      #
      def segment(levels, step=24)
        return levels.map{|l| [l.first, l.last.to_i] } if levels.all?{|l| l.last.to_f==0.0 }
        return levels.map{|l| [l.first, 24] } if levels.all?{|l| levels.first.last==l.last }
        max = Math.sqrt levels.inject(0){|r,c| (c.last > r)? c.last: r}
        min = Math.sqrt levels.inject(max){|r,c| (c.last < r)? c.last: r}
        factor = step/(max-min)
        levels.map{|l| [l.first, ((Math.sqrt(l.last)-min)*factor).round] }
      end
    end

    def initialize(sites=[])
      raise ArgumentError unless sites.kind_of? Array
      @sites, @summary = sites, {}
      segment_by_volume
      segment_by_frequency
    end

    #
    # POST量をみて評価
    #
    def segment_by_volume
      segment(@sites.map{|f| [f, f.volume] }).map do |site|
        @summary[site.first] ||= {}
        @summary[site.first][:volume_level] = site.last
      end
    end

    #
    # POST数をみて評価
    #
    def segment_by_frequency
      segment(@sites.map{|f| [f, f.frequency] }).map do |site|
        @summary[site.first] ||= {}
        @summary[site.first][:frequency_level] = site.last
      end
    end

    def segment(levels, step=24)
      self.class.segment(levels, step) end

    def method_missing(name, *args, &block)
      @summary.__send__ name, *args, &block end 

  end
end
