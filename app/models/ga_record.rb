class GaRecord < ActiveRecord::Base
	belongs_to :ga_export

	TAX = 1.22
	EMAZING_PERCENTAGE = 0.3

	hstore_accessor :data,
		date: :date,
		source: :string,
		campaign: :string,
		medium: :string,
		ad_content: :string,
		keyword: :string,
		ad_cost: :decimal,
		ad_clicks: :integer,
		sessions: :integer,
		item_quantity: :integer,
		transaction_revenue: :decimal,
		transactions: :integer

	def revenue
		(transaction_revenue/TAX)*EMAZING_PERCENTAGE
	end

	def profit
		revenue - ad_cost
	end

	def profitability
		if ad_cost == 0
			"n/a"
		else
			(profit/ad_cost*100).to_i
		end
	end

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

	scope :filter, -> (params = nil) do
		where_query = nil
		order_query = nil

    if params[:filter]
    	where_query = params[:filter].map { |attribute|
    		name = attribute.first
    		selected_values = attribute.last

    		or_query = selected_values.map { |value|
    			"data @> '#{name} => #{value}'"
    		}.
    		join(' OR ') }.
    		map { |query| "(#{query})" }.join(' AND ')
    end

    if params[:order]
    	by = params[:order][:by] || 'date'
    	direction = params[:order][:direction] || 'desc'

    	# dasdasasd
    	if COLUMN_HEADERS[by.to_sym][:summary_type] == :integer_sum
    		order_query = "LOWER(data -> '#{by}')::integer #{direction}"
    	elsif COLUMN_HEADERS[by.to_sym][:summary_type] == :float_sum
    		order_query = "LOWER(data -> '#{by}')::float #{direction}"
    	else
    		order_query = "LOWER(data -> '#{by}') #{direction}"
    	end
    end

    where(where_query).order(order_query)
	end

	scope :from_account, -> (account) { where(ga_exports: {profile_id: account.profile_id}).joins(:ga_export) }

end
