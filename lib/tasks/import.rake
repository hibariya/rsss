namespace :migrate do
  task import: :environment do
    users = YAML.load(STDIN.read)

    users.each do |_user|
      user = User.create!(_user.slice(:name, :url, :bio))

      _user[:authentications].each do |_authentication|
        user.authentications.create! _authentication
      end

      _user[:sites].each do |_site|
        user.sites.create! _site.slice(:title, :url, :feed_url) do |site|
          _site[:histories].each do |_history|
            site.histories.create! _history
          end
        end
      end
    end
  end
end
