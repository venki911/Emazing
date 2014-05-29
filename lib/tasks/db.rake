namespace :db do
  desc "Pull DB backup from production"
  task pull: :environment do
    puts `scp emazing:~/backups/emazing/latest.dump .`
    puts `psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'emazing_development' AND pid <> pg_backend_pid();"`
    puts `dropdb -U tomazzlender emazing_development`
    puts `createdb -U tomazzlender emazing_development`
    puts `pg_restore --clean --no-acl --no-owner -h localhost -U tomazzlender -d emazing_development latest.dump`
    puts `rm latest.dump`
  end
end
