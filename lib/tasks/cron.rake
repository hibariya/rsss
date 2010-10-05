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

  User.all.each{|user| user.update_summarized_categories! rescue nil }
  User.all.each{|user| user.update_summarized_near_users! rescue nil }
end

