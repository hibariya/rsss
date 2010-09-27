task :cron => :environment do
  User.all.each do |user|
    begin
      user.reload_user_info!
    rescue
      p $!
      p $@
    ensure
      begin
        user.create_histories!
      rescue
        p $!
        p $@
        next
      end
    end
  end
end

