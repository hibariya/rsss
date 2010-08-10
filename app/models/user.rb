class User
  include Mongoid::Document

  field :name, :type=>String
  field :site, :type=>String
  field :description, :type=>String
  field :feeds, :type=>Array
  field :caches, :type=>Array
  field :histories, :type=>Array
  field :created_at, :type=>Time
  field :updated_at, :type=>Time

  def summaries
    @summaries ||= Summaries.new(caches.empty?? reload_summaries.caches: caches) end

  #
  # 過去30日間の遷移を更新
  #
  def reload_summaries
    self.histories ||= []
    self.histories.push caches unless caches.empty?
    self.histories = self.histories.reverse[0...30].reverse
    self.caches = []
    get_feeds.each do |feed|
      self.caches.push({link: feed.link,
        title: feed.title,
        general_level: feed.general_level,
        volume_level: feed.volume_level,
        frequency_level: feed.frequency_level})
    end
    save && self
  end

  def get_feeds
    Feeds.new(feeds.map{|u| Feeds::Entries.new get_rss(u) }) end

  def get_rss(uri)
    uri = URI.parse(uri)
    uri.query = (uri.query.nil?? '' : uri.query+'&')+Time.now.to_i.to_s 
    uri.open{|f| RSS::Parser.parse f.read, false, true } end

  #
  # コンパクトなサイトの評価情報をまとめる何か
  #
  class Summaries
    def initialize(caches=[])
      raise ArgumentError unless caches.kind_of? Array
      @caches = caches.map{|c| Summary.new c }
    end
    
    def method_missing(name, *args, &block)
      if sortname = name.to_s.match(/^sort_by_([a-z]+)/)
        sortmethod = [sortname.captures.first,'_level'].join.intern
        @caches.sort_by{|c|c.__send__ sortmethod }.reverse
      else
        @caches.__send__ name, *args, &block
      end
    end

    #
    # サイトの情報と評価をコンパクトにした何か
    #
    class Summary
      def initialize(cache={})
        raise ArgumentError unless cache.kind_of? Hash
        @cache = cache end

      def method_missing(name, *args, &block)
        if @cache.keys.find{|k| k.intern==name.intern }
          @cache[name.intern] || @cache[name.to_s]
        else
          @cache.__send__ name, *args, &block
        end
      end
    end
  end

  #
  # フィードの一覧を相対評価するための何か
  #
  class Feeds
    attr_accessor :feeds

    def initialize(feeds=[])
      raise ArgumentError unless feeds.kind_of? Array
      @feeds = feeds
      segment_by_general
    end

    def method_missing(name, *args, &block)
      @feeds.__send__ name, *args, &block end

    #
    # POST量をみて評価
    #
    def segment_by_volume
      segment(@feeds.map{|f| [f, f.volume] }).map do |site|
        site.first.volume_level = site.last
        site
      end
    end

    #
    # POST数をみて評価
    #
    def segment_by_frequency
      segment(@feeds.map{|f| [f, f.frequency] }).map do |site|
        site.first.frequency_level = site.last
        site
      end
    end

    #
    # POST量とPOST数両方をみて評価
    #
    def segment_by_general
      volume = segment_by_volume
      frequency = segment_by_frequency
      volume.map do |v| 
        level = (v.last.to_f+frequency.find{|f| f.first.link==v.first.link}.last.to_f)/2
        v.first.general_level = level.round
        [v.first, level]
      end
    end

    #
    # 24点満点の相対評価を行う
    #
    def segment(levels, step=24)
      max = Math.sqrt levels.inject(0){|r,c| (c.last > r)? c.last: r}
      min = Math.sqrt levels.inject(max){|r,c| (c.last < r)? c.last: r}
      factor = step/(max-min)
      levels.map{|l| [l.first, ((Math.sqrt(l.last)-min)*factor).round] }
    end

    #
    # 1サイトのフィードに相当する部分
    #
    class Entries
      attr_accessor :feed, :entries
      attr_accessor :volume_level, :frequency_level, :general_level
  
      def initialize(feed)
        raise ArgumentError unless [RSS::RDF, RSS::Atom::Feed, RSS::Rss].any?{|c| feed.kind_of? c }
        @feed, @entries = feed, (feed.respond_to?(:entries)? feed.entries: feed.items).map{|e| Entry.new e }
      end

      #
      # サイトの1日当たりのPOST量(byte)
      #
      def volume
        count_daily byte_length end

      #
      # サイトの1日当たりのPOST数
      #
      def frequency
        count_daily length end

      #
      # 全体の量を日数で割って1日あたりどれくらいかなんとなく出す
      #
      def count_daily(param, now=Time.now)
        param.to_f/day_length(now) end

      #
      # そのフィードが何秒分に相当するか
      # 15日以上のブランクは影響が大きすぎるのでカウントしないでやってみる
      #
      def time_length(now=Time.now)
        now = now.to_i
        #simple = now-earliest_date.to_i
        blank_limit = 86400*15
        @entries.sort_by{|e| e.date }.reverse.map{|e| e.date.to_i }.inject([now, 0]) do |cur, time|
          cur ||= [now, 0]
          draft = cur.first-time
          [time, cur.last+((draft > blank_limit)? blank_limit: draft)]
        end.last
      end

      #
      # そのフィードが何日分に相当するか
      #
      def day_length(now=Time.now)
        time_length(now).to_f/86400 end

      #
      # フィード内の全ての記事のタイトルと本文のバイト数をざっくりと
      #
      def byte_length
        @entries.map{|e| [e.title, e.content].join }.flatten.join.length
      end

      #
      # サイト名
      #
      def title
        @title ||= @feed.respond_to?(:title)? 
          @feed.title.content: @feed.channel.title end
 
      #
      # サイトURL
      #
      def link
        @link ||= @feed.respond_to?(:link)?
          @feed.link.href: @feed.channel.link end

      #
      # フィードの中で一番昔の日付
      #
      def earliest_date
        @entries.inject(nil){|r,c| r||=c.date; (r>c.date)? c.date: r } end
  
      #
      # フィードの中で最新の日付
      #
      def latest_date
        @entries.inject(nil){|r,c| r||=c.date; (r<c.date)? c.date: r } end
  
      def method_missing(name, *args, &block)
        @entries.__send__ name, *args, &block end
 
      #
      # フィード中の1エントリーに相当する部分
      #
      class Entry
        attr_reader :entry

        def initialize(entry)
          raise ArgumentError unless [RSS::RDF::Item, RSS::Atom::Feed::Entry, RSS::Rss::Channel::Item].
            any?{|c| entry.kind_of? c }
          @entry = entry
        end

        #
        # エントリのタイトルに相当しそうな部分を取得
        #
        def title
          @title ||= [:title].inject(nil) do |res, m|
            if @entry.respond_to?(m)  && !@entry.__send__(m).nil? && res.nil?
              res = @entry.__send__ m 
              res.respond_to?(:content)? res.content: res
            else res end
          end
        end
        
        #
        # エントリのコンテンツ本体に相当しそうな部分
        #
        def content
          @content ||= [:content_encoded, :content, :description, :summary, :subtitle].inject(nil) do |res, m|
            if @entry.respond_to?(m)  && !@entry.__send__(m).nil? && res.nil?
              res = @entry.__send__ m 
              res.respond_to?(:content)? res.content: res
            else res end
          end
        end
   
        #
        # カテゴリ的なもの
        #
        def categories
          @categories ||= [:categories, :dc_subjects, :dc_categories].inject([]) do |res, m|
            if @entry.respond_to?(m)  && !@entry.__send__(m).nil?
              (res+@entry.__send__(m).map{|c| c.respond_to?(:content)? c.content: c }).uniq
            else res end
          end
        end
 
        #
        # 日付っぽいもの
        #
        def date
          @date ||= [:published, :pubDate, :date, :updated, :dc_date].inject(nil) do |res, m|
            if @entry.respond_to?(m)  && !@entry.__send__(m).nil? && res.nil?
              res = @entry.__send__ m 
              res.respond_to?(:content)? res.content: res
            else res end
          end
        end
      end
  
    end
  end

end
