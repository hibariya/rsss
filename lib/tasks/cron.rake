task :cron => :environment do
  User.all.each do |user|
    begin
      user.reload_user_info!
      user.create_histories!
      #user.be_skinny!
    rescue
      p $!
      p $@
    end
  end
end

