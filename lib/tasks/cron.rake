task :cron => :environment do
  User.all.each do |user|
    begin
      user.reload_user_info!
      user.create_histories!

      now = Time.now
      user.sites.map do |site|
        if site.entries.length>5
          site.entries[5..-1].
            select{|e| (e.date.to_i+86400) < now.to_i }.
            map(&:delete)
        end
      end
    rescue
      p $!
      p $@
    end
  end
end

