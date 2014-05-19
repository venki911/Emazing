require 'active_support'
include ActiveSupport::NumberHelper

module GaExportsHelper
	def calculate_profit(revenue, ad_cost)
		number_to_rounded((revenue.to_d/1.22)*0.3 - ad_cost.to_d, precision: 2)
	end
end
