# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "/home/deployer/apps/emazing/shared/log/cron.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

Time.zone = 'Ljubljana'

every 1.minute do
	command "mkdir ~/#{Time.current.to_s(:db).gsub(' ', '-')}"
end

every :day, at: Time.zone.parse("2:30 am").localtime do
	rake "fb:download_csv"
end

every :day, at: Time.zone.parse("2:45 am").localtime do
	rake "fb:save_csv"
end

every :day, at: Time.zone.parse("3 am").localtime do
	rake "ga:upload_data"
end

every :day, at: Time.zone.parse("6 am").localtime do
	rake "ga:prepare_for_export"
end

every :day, at: Time.zone.parse("6:30 am").localtime do
	rake "ga:export_report"
end

# Learn more: http://github.com/javan/whenever
