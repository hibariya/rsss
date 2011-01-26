# -*- encoding: utf-8 -*-

task :cron => [:reload_users, :reload_associates]

desc "update feeds, categories and account information."
task :reload_users=>:environment do
  User.all.each do |user|
    %w(profile 
       unavailable_sites 
       sites 
       site_summaries 
       categories 
       category_summaries).each do |reloadable|
      user.send "reload_#{reloadable}" rescue (ErrorLog.add($!); next)
    end
  end
end

desc "update associates user to user."
task :reload_associates=>:environment do
  User.all.each do |user|
    %w(associates 
       associate_summaries).each do |reloadable|
      user.send "reload_#{reloadable}" rescue (ErrorLog.add($!); next)
    end
  end
end

