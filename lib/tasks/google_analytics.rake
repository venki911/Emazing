require "google/api_client"
require "csv"

namespace :ga do
  desc "Upload data to Google Analytics"
  task :upload_data => [:environment] do
    puts "GA:UPLOAD_DATA: Starting at #{Time.now.to_s(:long)}..."

    # I. input
    ga_account = GaAccount.first
    csv_report = CsvReport.last

    source = csv_report.source
    recorded_at = csv_report.recorded_at.to_s(:db)

    # II. prepare data for upload
    csv = CSV.generate do |row|
      # headers
      row << ["ga:source", "ga:medium", "ga:campaign", "ga:adContent", "ga:impressions", "ga:adClicks", "ga:adCost"]

      # cost data
      CSV.parse(csv_report.source) do |source_row|
        # skip first line with headers
        next if source_row.first == 'Start Date'
        next if source_row.first == 'No data available.'

        # remove row if campaign is not related to medex
        if source_row[2] == 'medex'
          row << ['emazing', 'facebook', 'medex', source_row[3], source_row[4], source_row[6], source_row[5]]
        end
      end
    end
    string_io = StringIO.new(csv)

    # III. upload!
    # (string_io, recorded_at, account_id, custom_data_source_id, web_property_id)
    GoogleAnalytics::CustomData.upload!(string_io, recorded_at, ga_account.account_id, ga_account.custom_data_source_id, ga_account.web_property_id)

    puts "Finished."
  end

  desc "Export report from Google Analytics"
  task :export_report => [:environment] do
    puts "GA:EXPORT_REPORT: Starting at #{Time.now.to_s(:long)}..."
    @ga_export = GaExport.last
    @ga_export.export_data_from_ga
  end

  desc "Prepare blank daily report for export"
  task :prepare_for_export => [:environment] do
    puts "GA:PREPARE_FOR_EXPORT: Starting at #{Time.now.to_s(:long)}..."
    @current_ga_account = GaAccount.find_by alias: "www.medex.si"
    @ga_export = GaExport.create(start_date: 0.day.ago.to_date, end_date: 0.day.ago.to_date, profile_id: @current_ga_account.profile_id)
  end
end
