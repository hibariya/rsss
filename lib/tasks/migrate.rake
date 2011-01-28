
namespace :migrate do
  desc "extract from old type users to yaml file"
  task :extract => :environment do
    require Rails.root.join('lib', 'migration_utility')

    migrate_users = User.all.map{|user| MigrationUtility.user_to_struct user }
    File.open(Rails.root.join('migrate_users.yml'), 'w'){|f| f.puts migrate_users.to_yaml }
  end

  desc "import (old type users) yaml file to database"
  task :import => :environment do
    require Rails.root.join('lib', 'migration_utility')
    YAML.load_file(ENV['from']).map{|user| MigrationUtility.struct_to_user user }
  end
end


