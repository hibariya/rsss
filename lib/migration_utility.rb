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
                       :histories

  Site    = Struct.new :uri,
                       :site_uri,
                       :title

  History = Struct.new :volume_level,
                       :frequency_level,
                       :created_at,
                       :site_uri

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
      migrate_user
    end

    def site_to_struct(site)
      Site.new site.uri, site.site_uri, site.title
    end

    def history_to_struct(h)
      History.new h.volume_level, h.frequency_level, h.created_at, h.site.uri
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
    end
  end
end

