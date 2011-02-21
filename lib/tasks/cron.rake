# coding: utf-8

task :cron => [:reload_profile,
               :reload_sites,
               :reload_site_summaries,
               :reload_categories,
               :reload_category_summaries,
               :reload_associates,
               :reload_associate_summaries]

desc "reload profile" 
task :reload_profile => :environment do
  User.all.each do |user|
    user.reload_profile rescue (ErrorLog.add($!); next)
  end
end

desc "reload sites" 
task :reload_sites => :environment do
  User.all.each do |user|
    user.reload_sites rescue (ErrorLog.add($!); next)
  end
end

desc "reload site summaries" 
task :reload_site_summaries => :environment do
  User.all.each do |user|
    user.reload_site_summaries rescue (ErrorLog.add($!); next)
  end
end

desc "reload categories"
task :reload_categories => :environment do
  User.all.each do |user|
    user.reload_categories rescue (ErrorLog.add($!); next)
  end
end

desc "reload category summaries"
task :reload_category_summaries => :environment do
  User.all.each do |user|
    user.reload_category_summaries rescue (ErrorLog.add($!); next)
  end
end

desc "reload associates"
task :reload_associates => :environment do
  User.all.each do |user|
    user.reload_associates rescue (ErrorLog.add($!); next)
  end
end

desc "reload associate summaries"
task :reload_associate_summaries => :environment do
  User.all.each do |user|
    user.reload_associate_summaries rescue (ErrorLog.add($!); next)
  end
end

