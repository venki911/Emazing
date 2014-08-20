class String
	def keyify
		titleize.gsub(/[^a-z0-9\s]/i, '').squish.gsub(' ', '_').downcase
	end
end