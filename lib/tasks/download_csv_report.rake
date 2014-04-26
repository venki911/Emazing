namespace :fb do
	desc "Downloads CSV Report from Facebook"
	task :download_csv => [:environment] do
		puts "Starting..."

		username = Rails.application.secrets.facebook_username
		password = Rails.application.secrets.facebook_password
		temp_csv_path = Rails.root.join('tmp', 'cache', 'fb_csvs', "smania_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv")
		facebook_ads_account_id = Rails.application.secrets.facebook_ads_account_id
		script = Rails.root.join('lib', 'tasks', 'download_csv_report.js')

		output = `casperjs --web-security=no --facebook-username=#{username} --facebook-password=#{password} --facebook-ads-account-id=#{facebook_ads_account_id} --temp-csv-path=#{temp_csv_path} #{script}`
		puts output

		line_with_path_prefix = "CSV downloaded: "
		filter_line_with_path = output.split(/\r?\n/).select { |line| line.start_with?(line_with_path_prefix)}.first

		if filter_line_with_path
			csv_file_path = filter_line_with_path.gsub(line_with_path_prefix, '')
			puts csv_file_path
		end

		puts "Finished."
	end

	desc "Saves CSV report to db"
	task :save_csv => [:environment] do
		csv_report = CsvReport.new
		csv_report.source = File.read(Rails.root.join('tmp', 'cache', 'fb_csvs', 'smania_20140426150214.csv'))
		csv_report.recorded_at = '2014-04-25'
		csv_report.facebook_ads_account_id = Rails.application.secrets.facebook_ads_account_id
		csv_report.save
		puts csv_report.inspect
	end
end
