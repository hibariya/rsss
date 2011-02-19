class UserPresenter
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def sites_by_score
    @sites_by_score ||= sites.sort_by{|site| site.summary.score }.reverse
  end

  def recent_entries(limit=-1)
    entries.sort_by(&:date).reverse[0...limit]
  end

  def recent_entries_by_category(category_name)
    recent_entries.select do |entry|
      entry.categories.map(&:downcase).include? category_name
    end
  end

  def categories_by_frequency(limit=-1)
    categories.sort_by(&:frequency).reverse[0..limit].sort_by(&:name)
  end

  def associates_by_score(limit=-1)
    associates.sort_by(&:score).reverse[0..limit]
  end

  def entries
    @entries ||= sites.map(&:entries).flatten.sort_by(&:date).reverse
  end

  def categories
    @categories ||= @user.categories.map{|c| CategoryPresenter.new c, @user }
  end

  def associates
    @associates ||= @user.associates.map{|a| AssociatePresenter.new a, @user }
  end

  def sites
    @sites ||= @user.sites.map{|s| SitePresenter.new s, @user }.select(&:summaries?)
  end

  def sites?
    !sites.empty?
  end

  def has_profile?
    @user.site? || @user.description?
  end

  def categories?
    !categories.empty?
  end

  def associates?
    !associates.empty?
  end

  def to_feed
    user_page_base = "http://rsss.be/users/#{screen_name}"
    RSS::Maker.make('1.0') do |maker|
      maker.channel.about = "#{user_page_base}.xml"
      maker.channel.title = "RSSS | #{screen_name}"
      maker.channel.description =  "RSSS Feed: #{screen_name} #{description}"
      maker.channel.link = user_page_base
      maker.channel.author = screen_name
      maker.channel.date = updated_at || Time.now
      maker.items.do_sort = true

      feed_entries maker, recent_entries
    end
  end

  def category_feed(category)
    category.downcase!
    category_page_base = "http://rsss.be/users/#{screen_name}/#{category}"
    RSS::Maker.make('1.0') do |maker|
      maker.channel.about = "#{category_page_base}.xml"
      maker.channel.title = "RSSS | #{screen_name} | #{category}"
      maker.channel.description =  "RSSS Feed: #{screen_name} #{category}"
      maker.channel.link = category_page_base
      maker.channel.author = screen_name
      maker.channel.date = updated_at || Time.now
      maker.items.do_sort = true

      feed_entries maker, recent_entries_by_category(category)[0..99]
    end
  end

  class << self
    def load_by_screen_name(screen_name)
      new User.by_screen_name(screen_name).first
    end

    alias load load_by_screen_name

    delegate :model_name, :to => User
  end

  private

    def feed_entries(maker, entries)
      if entries.empty?
        maker.items.new_item do |item| 
          item.title = 'Created'
          item.link = maker.channel.link
          item.date = maker.channel.date
        end
      else
        entries.each do |entry|
          maker.items.new_item do |item|
            %w(link title date description).each do |attr|
              item.send "#{attr}=", entry.send(attr)
            end

            entry.categories.each do |category_name|
              item.categories.new_category{|c| c.content = c.term = category_name }
              item.dc_subjects.new_subject{|c| c.value = category_name }
            end
          end
        end
      end
    end

    # TODO: remove 
    def method_missing(name, *args)
      @user.respond_to?(name)?
        @user.send(name, *args):
        @user.auth_profile.send(name, *args)
    end

end
