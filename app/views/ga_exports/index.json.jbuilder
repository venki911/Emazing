json.cache! [@ga_records.map(&:id), params] do
	json.params do
		json.order params[:order]
		json.filter do
			params[:filter] ||= {}
			
			json.source params[:filter][:source] || []
			json.campaign params[:filter][:campaign] || []
			json.medium params[:filter][:medium] || []
			json.ad_content params[:filter][:ad_content] || []
			json.keyword params[:filter][:keyword] || []
		end
		json.daterange params[:daterange]
	end
	json.data do
		json.column_headers do
			summaries = GaRecord.summaries(@ga_records)

			json.array!(GaRecord::COLUMN_HEADERS) do |header|
				json.title header.last[:title]
				json.name header.first.to_s
				json.summary do
					json.type summaries[header.first][:type]
					json.value summaries[header.first][:value]
				end
				json.options GaRecord.with_calculated_attrs.from_account(@current_ga_account).map {|record| record.send(header.first)}.uniq
			end
		end

		json.rows do
			column_headers = GaRecord.column_headers

			json.array!(@ga_records) do |ga_record|
				column_headers.each do |column|
					value = ga_record.send(column)
					json.set! column, value
				end
			end
		end
	end
end