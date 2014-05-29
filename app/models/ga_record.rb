class GaRecord < ActiveRecord::Base
	belongs_to :ga_export

  COLUMN_HEADERS =
    {date: {title: "Date", summary_type: :date_filter},
     source: {title: "Source", summary_type: :text_filter},
     campaign: {title: "Campaign", summary_type: :text_filter},
     medium: {title: "Medium", summary_type: :text_filter},
     ad_content: {title: "Ad Content", summary_type: :text_filter},
     keyword: {title: "Keyword", summary_type: :text_filter},
     ad_cost: {title: "Ad Cost", summary_type: :float_sum},
     ad_clicks: {title: "Ad Clicks", summary_type: :integer_sum},
     sessions: {title: "Sessions", summary_type: :integer_sum},
     item_quantity: {title: "Item Quantity", summary_type: :integer_sum},
     transaction_revenue: {title: "Trans. Revenue", summary_type: :float_sum},
     transactions: {title: "Transactions", summary_type: :integer_sum},
     revenue: {title: "Revenue", summary_type: :custom_sum},
     profit: {title: "Profit", summary_type: :custom_sum},
     profitability: {title: "Profitability", summary_type: :custom_sum}}

	TAX = 1.22
	EMAZING_PERCENTAGE = 0.3
	FORMULA = {}

	FORMULA[:date] = "to_date((data -> 'date'), 'YYYY-MM-DD')"
	def date() attributes['date'] end

	FORMULA[:source] = "data -> 'source'"
	def source() attributes['source'] end

	FORMULA[:campaign] = "data -> 'campaign'"
	def campaign() attributes['campaign'] end

	FORMULA[:medium] = "data -> 'medium'"
	def medium() attributes['medium'] end

	FORMULA[:ad_content] = "data -> 'ad_content'"
	def ad_content() attributes['ad_content'] end

	FORMULA[:keyword] = "data -> 'keyword'"
	def keyword() attributes['keyword'] end

	FORMULA[:ad_cost] = "(data -> 'ad_cost')::float"
	def ad_cost() attributes['ad_cost'].to_d end

	FORMULA[:ad_clicks] = "(data -> 'ad_clicks')::integer"
	def ad_clicks() attributes['ad_clicks'] end

	FORMULA[:sessions] = "(data -> 'sessions')::integer"
	def sessions() attributes['sessions'] end

	FORMULA[:item_quantity] = "(data -> 'item_quantity')::integer"
	def item_quantity() attributes['item_quantity'] end

	FORMULA[:transaction_revenue] = "(data -> 'transaction_revenue')::float"
	def transaction_revenue() attributes['transaction_revenue'].to_d end

	FORMULA[:transactions] = "(data -> 'transactions')::integer"
	def transactions() attributes['transactions'] end

	FORMULA[:revenue] = "#{FORMULA[:transaction_revenue]}/#{TAX}*#{EMAZING_PERCENTAGE}"
	def revenue() attributes['revenue'].to_d end

	FORMULA[:profit] = "(#{FORMULA[:revenue]} - #{FORMULA[:ad_cost]})"
	def profit() attributes['profit'].to_d end

	FORMULA[:profitability] = %Q{
		CASE
		  WHEN #{FORMULA[:ad_cost]} = 0
		  THEN NULL
		  ELSE (#{FORMULA[:profit]}/#{FORMULA[:ad_cost]}*100)
		  END
		}
	def profitability() attributes['profitability'].to_i unless attributes['profitability'] == nil end

  scope :with_calculated_attrs, -> { select "ga_records.id, " + COLUMN_HEADERS.map {|column| name = column.first; "#{FORMULA[name]} as #{name}"}.join(', ') }

	def self.column_headers
		COLUMN_HEADERS.map(&:first)
	end

	def self.summaries(records)
		summaries = {}

		COLUMN_HEADERS.each do |column|
			value = case column.last[:summary_type]
			when :date_filter
				"Date Filter"
			when :text_filter
				"Filter"
			when :float_sum
				records.sum("(data -> '#{column.first}')::float")
			when :integer_sum
				records.sum("(data -> '#{column.first}')::integer")
			when :custom_sum
				revenue = (records.sum("(data -> 'transaction_revenue')::float")/TAX)*EMAZING_PERCENTAGE
				ad_cost = records.sum("(data -> 'ad_cost')::float")
				profit = revenue - ad_cost
				profitability = (if ad_cost == 0 then "n/a" else (profit/ad_cost*100).to_i end)

				sum = revenue if column.first == :revenue
				sum = profit if column.first == :profit
				sum = profitability if column.first == :profitability
				sum
			else
				""
			end

			summaries[column.first] = {type: column.last[:summary_type], value: value}
		end

		summaries
	end

	scope :filter_by, -> (params_filter = nil) do
		where_query = nil

    if params_filter
    	where_query = params_filter.map { |attribute|
    		name = attribute.first
    		selected_values = attribute.last

    		or_query = selected_values.map { |value|
    			"(#{FORMULA[name.to_sym]}) = '#{value}'"
    		}.
    		join(' OR ') }.
    		map { |query| "(#{query})" }.join(' AND ')
    end
    
    where(where_query)
	end

	scope :sort_by, -> (params_order) do
		params_order ||= {}
    params_order[:by] ||= 'date'
    params_order[:direction] ||= 'desc'

    if params_order[:by] == 'profitability'
    	secundary_order_column = 'profit'
    else
    	secundary_order_column = 'ga_records.id'
    end

    order("#{params_order[:by]} #{params_order[:direction]}, #{secundary_order_column} #{params_order[:direction]}")
	end

	scope :from_account, -> (account) { where(ga_exports: {profile_id: account.profile_id}).joins(:ga_export) }

end
