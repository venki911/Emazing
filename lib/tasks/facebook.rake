namespace :fb do
	desc "Downloads CSV Report from Facebook"
	task :download_csv => [:environment] do
		puts "FB:DOWNLOAD_CSV: Starting at #{Time.current.to_s(:long)}..."

		username = Rails.application.secrets.facebook_username
		password = Rails.application.secrets.facebook_password
		temp_csv_path = Rails.root.join('tmp', 'cache', 'fb_csvs', "medex_#{Date.yesterday.to_s(:db)}_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv")
		facebook_ads_account_id = Rails.application.secrets.facebook_ads_account_id
		facebook_report_tag = 'ID01'
		script = Rails.root.join('lib', 'tasks', 'download_csv_report.js')

		# download from facebook
		output = `casperjs --web-security=no --facebook-username=#{username} --facebook-password=#{password} --facebook-ads-account-id=#{facebook_ads_account_id} --facebook-report-tag=#{facebook_report_tag} --temp-csv-path=#{temp_csv_path} #{script}`
		puts output

		# save to database
		line_with_path_prefix = "CSV downloaded: "
		filter_line_with_path = output.split(/\r?\n/).select { |line| line.start_with?(line_with_path_prefix)}.first

		if filter_line_with_path
			file_path = filter_line_with_path.gsub(line_with_path_prefix, '')
			report_tag = facebook_report_tag
			source_name = 'facebook'

			Report.import_from_csv!(file_path: file_path, source_name: source_name, tag: report_tag)
		end

		puts "Finished."
	end
end
