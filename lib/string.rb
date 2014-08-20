class String
	def keyify
		titleize.gsub(/[^a-z0-9\s]/i, '').squeeze.gsub(' ', '_').downcase
	end
end