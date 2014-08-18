require "csv"

class Report < ActiveRecord::Base
	has_many :records, dependent: :destroy

	def self.import_from_csv!(args)
		file_path = args[:file_path]
		source_name = args[:source_name]
		tag = args[:tag]

		csv = CSV.parse(File.read(file_path))

		keys = csv.first.map(&:keyify) # transforms "Campaign Name" to "campaign_name"
		rows = csv - [csv.first] # rows without header row

		Report.transaction do
			report = Report.new source_name: source_name, tag: tag

			rows.each do |row|
				data = row.map.with_index {|element, index| [keys[index], element]}.to_h # {"campaign_name" => "Awesome Campaign Name", ...}

				record = Record.new data: data
				report.records << record
			end

			report.save
		end
	end
end
