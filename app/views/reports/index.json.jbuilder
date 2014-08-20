json.cache! [@records.map(&:id), params] do
	# json.params do
	# 	json.order params[:order]
	# 	json.filter do
	# 		params[:filter] ||= {}
			
	# 		json.source params[:filter][:source] || []
	# 		json.campaign params[:filter][:campaign] || []
	# 		json.medium params[:filter][:medium] || []
	# 		json.ad_content params[:filter][:ad_content] || []
	# 		json.keyword params[:filter][:keyword] || []
	# 	end
	# 	json.daterange params[:daterange]
	# end
	json.data do
		json.column_headers do
			# summaries = GaRecord.summaries(@ga_records)

			json.array!(Record::REPORT_FIELDS[@report_tag]) do |field_name|
				json.title field_name.to_s.gsub('_', ' ').titlecase
				json.name field_name
				json.type Record::FIELD[field_name][:type].to_s
				# json.summary do
				# 	json.type summaries[field.first][:type]
				# 	json.value summaries[field.first][:value]
				# end
				# json.options GaRecord.with_calculated_attrs.from_account(@current_ga_account).map {|record| record.send(field.first)}.uniq
			end
		end

		json.rows do
			json.array!(@records) do |record|
				Record.fields.each do |name|
					value = record.send(name)
					json.set! name, value
				end
			end
		end
	end
end