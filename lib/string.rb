class String
	def keyify
		titleize.gsub(/[^a-z0-9\s]/i, '').gsub(' ', '').underscore
	end
end