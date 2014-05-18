class GaExport < ActiveRecord::Base
	has_many :ga_records, dependent: :destroy

	def export_data_from_ga
		export_results = GoogleAnalytics::Reports.export(self.profile_id, self.start_date.to_s(:db))

    self.column_headers = export_results.data.column_headers.map(&:name)
    self.ga_records.destroy_all

    export_results.data.rows.each do |row|
      self.ga_records.build(data: row)
    end

    self.save
	end
end
