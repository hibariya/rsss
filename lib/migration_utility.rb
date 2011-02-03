module MigrationUtility
  User    = Struct.new :description,
                       :site,
                       :token,
                       :screen_name,
                       :oauth_user_id,
                       :oauth_token,
                       :oauth_secret,
                       :oauth_description,
                       :oauth_name,
                       :profile_image_url,
                       :sites,
                       :histories,
                       :summarized_near_users,
                       :summarized_categories

  Site    = Struct.new :uri,
                       :site_uri,
                       :title

  History = Struct.new :volume_level,
                       :frequency_level,
                       :created_at,
                       :site_uri

  SummarizedCategory = Struct.new :category, :level, :date
  SummarizedNearUser = Struct.new :screen_name, :level, :date

  class << self
    def user_to_struct(user)
      migrate_user = User.new user.description,
                              user.site,
                              user.token,
                              user.screen_name,
                              user.oauth_user_id,
                              user.oauth_token,
                              user.oauth_secret,
                              user.oauth_description,
                              user.oauth_name,
                              user.profile_image_url

      migrate_user.sites     = user.sites.map{|s| site_to_struct s }
      migrate_user.histories = user.sites.map(&:histories).flatten.map{|h| history_to_struct h }

      migrate_user.summarized_near_users = user.summarized_near_users.map do |s| 
        summarized_near_user_to_struct s
      end

      migrate_user.summarized_categories = user.summarized_categories.map do |s|
        summarized_category_to_struct s unless s.strip.empty?
      end
      migrate_user
    end

    def site_to_struct(site)
      Site.new site.uri, site.site_uri, site.title
    end

    def history_to_struct(h)
      History.new h.volume_level, h.frequency_level, h.created_at, h.site.uri
    end

    def summarized_near_user_to_struct(s)
      SummarizedNearUser.new s.screen_name, s.level, Date.today
    end

    def summarized_category_to_struct(s)
      SummarizedCategory.new s.category, s.level, Date.today
    end


    def struct_to_user(struct)
      user = ::User.new :description => struct.description,
                        :site        => struct.site,
                        :token       => struct.token

      user.auth_profile = AuthProfile.new :screen_name       => struct.screen_name,
                                          :user_id           => struct.oauth_user_id,
                                          :token             => struct.oauth_token,
                                          :secret            => struct.oauth_secret,
                                          :description       => struct.oauth_description,
                                          :name              => struct.oauth_name,
                                          :profile_image_url => struct.profile_image_url
      user.save!
      struct.sites.each do |s|
        ::Site.create! :uri      => s.uri.strip,
                       :site_uri => s.site_uri.strip,
                       :title    => s.title,
                       :user     => user
      end

      struct.summarized_categories.each do |summarized_category|
        Category.create!(:name      => summarized_category.category,
                         :frequency => summarized_category.level,
                         :user      => user)
      end

      struct.histories.each do |history|
        user.site_summaries<< SiteSummary.new(:site_id         => user.sites.where(:uri => history.site_uri).first.id,
                                              :date            => history.created_at,
                                              :frequency_score => history.frequency_level,
                                              :volume_score    => history.volume_level)
      end
      user.save!

      # CategorySummary  => 1世代分しかないのでmigrate後に再度計算しなおす
      # Associate        => 同上
      # AssociateSummary => 同上
    end
  end
end

