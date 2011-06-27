namespace :migrate do
  task export: :environment do
    users= []

    User.all.each do |user|
      users << {
        name: user.screen_name,
        bio:  user.description,
        url:  user.site,
        authentications: [{
          provider: 'twitter',
          uid:      user.oauth_user_id
        }],
        sites: user.sites.map {|site|
          {
            title:    site.title,
            url:      site.site_uri,
            feed_url: site.uri,
            histories: site.histories.map {|history|
              {
                volume_score:    history.volume_level,
                frequency_score: history.frequency_level,
                date:            history.created_at.beginning_of_day
              }
            }
          }
        }
      }
    end

    puts users.to_yaml
  end
end
