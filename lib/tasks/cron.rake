task :cron => :environment do
  User.all.each do |user|
    user.create_histories
  end
end

