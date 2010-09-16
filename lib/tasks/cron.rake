task :cron => :environment do
  User.all.each do |user|
    begin
      user.reload_user_info!
      user.create_histories!
    rescue
      p $!
    end
  end
end

