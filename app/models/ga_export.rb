class GaExport < ActiveRecord::Base
	has_many :ga_records, dependent: :destroy

	def export_data_from_ga
		export_results = GoogleAnalytics::Reports.export(self.profile_id, self.start_date.to_s(:db))
    
    self.ga_records.destroy_all

    column_headers = export_results.data.column_headers.map {|header| header.name.split(':').last.underscore} # ga:adClicks => ad_clicks

    export_results.data.rows.each do |row|
      data = {date: self.start_date}
      row.each_with_index do |value, index|
        attribute_name = column_headers[index]
        data[attribute_name] = value
      end

      self.ga_records.build(data: data)
    end

    self.save
	end
end
