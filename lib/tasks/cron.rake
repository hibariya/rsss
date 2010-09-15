task :cron => :environment do
  User.all.each{|u| u.create_histories }
end

