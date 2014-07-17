json.cache! [@ga_records.map(&:id), params] do
	json.column_headers do
		summaries = GaRecord.summaries(@ga_records)

		json.array!(GaRecord::COLUMN_HEADERS) do |header|
			json.title header.last[:title]
			json.name header.first.to_s
			json.summary do
				json.type summaries[header.first][:type]
				json.value summaries[header.first][:value]
			end
			json.options @ga_records.map {|record| record.send(header.first)}.uniq
		end
	end

	json.rows do
		column_headers = GaRecord.column_headers

		json.array!(@ga_records) do |ga_record|
			# hide non-emazing data
			# if ga_record.source == 'emazing'
			# 	ga_record.column_headers.each do |column|
			# 		value = ga_record.send(column)
			# 		if value.class == BigDecimal
			# 			json.set! column, number_to_currency(value)
			# 		else
			# 			json.set! column, value
			# 		end
			# 	end
			# else
			# 	ga_record.column_headers.each do |column|
			# 		if [:ad_cost, :ad_clicks, :sessions, :revenue, :profit, :profitability].include?(column)
			# 			json.set! column, ""
			# 		else
			# 			value = ga_record.send(column)
			# 			if value.class == BigDecimal
			# 				json.set! column, number_to_currency(value)
			# 			else
			# 				json.set! column, value
			# 			end
			# 		end
			# 	end
			# end

			column_headers.each do |column|
				value = ga_record.send(column)
				json.set! column, value
			end
		end
	end
end