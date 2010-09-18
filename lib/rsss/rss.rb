module Rsss
  module Rss

    class << self
      def get(uri)
        RSS::Parser.parse(fetch(uri), false, true) end

      def fetch(uri)
        u = URI.parse(uri)
        u.query = (u.query.nil?? '' : u.query+'&')+Time.now.to_i.to_s 
        u.open{|f| f.read }
      end
    end

    #
    # フィード中の1エントリーに相当する部分
    # RSSのインスタンスからそれっぽい項目を抽出すう
    #
    class Entry
      attr_reader :entry

      class << self
        def extract(entry)
          self.new(entry) end
      end

      def initialize(entry)
        raise ArgumentError unless [RSS::RDF::Item, RSS::Atom::Feed::Entry, RSS::Rss::Channel::Item].
          any?{|c| entry.kind_of? c }
        @entry = entry
      end

      #
      # Entryインスタンスとして返す
      #
      def to_entry
        ::Entry.new([:title, :content, :link, :categories, :date].
                  inject({}){|r,a|r.merge({a.intern=>self.send(a)})})
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
        end or ''
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
        end or ''
      end

      #
      # エントリのURIに相当しそうな部分
      #
      def link
        @link ||= [:about, :link].inject(nil) do |res, m|
          if @entry.respond_to?(m)  && !@entry.__send__(m).nil? && res.nil?
            res = @entry.__send__ m 
            res.respond_to?(:href)? res.href: res
          else res end
        end
      end

      #
      # カテゴリ的なもの
      #
      def categories
        @categories ||= [:categories, :dc_subjects, :dc_categories].inject([]) do |res, m|
          if @entry.respond_to?(m)  && !@entry.__send__(m).nil?
            (res+@entry.__send__(m).map{|c| (c.respond_to?(:content)? c.content: c) or '' }).uniq
          else res end
        end or []
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
