class Record < ActiveRecord::Base
	belongs_to :report

	FIELD = {}
	FIELD[:age] = {formula: "data -> 'age'", type: 'string'}
	FIELD[:reach] = {formula: "(data -> 'reach')::integer", type: 'integer'}
	FIELD[:advert] = {formula: "data -> 'advert'", type: 'string'}
	FIELD[:clicks] = {formula: "(data -> 'clicks')::integer", type: 'integer'}
	FIELD[:gender] = {formula: "data -> 'gender'", type: 'string'}
	FIELD[:campaign] = {formula: "data -> 'campaign'", type: 'string'}
	FIELD[:end_date] = {formula: "to_date((data -> 'end_date'), 'YYYY-MM-DD')", type: 'date'}
	FIELD[:advert_id] = {formula: "(data -> 'advert_id')::bigint", type: 'integer'}
	FIELD[:frequency] = {formula: "(data -> 'frequency')::float", type: 'float'}
	FIELD[:spend_eur] = {formula: "(data -> 'spend_eur')::float", type: 'currency'}
	FIELD[:account_id] = {formula: "(data -> 'account_id')::bigint", type: 'integer'}
	FIELD[:advert_set] = {formula: "data -> 'advert_set'", type: 'string'}
	FIELD[:page_likes] = {formula: "(data -> 'page_likes')::integer", type: 'integer'}
	FIELD[:start_date] = {formula: "to_date((data -> 'start_date'), 'YYYY-MM-DD')", type: 'date'}
	FIELD[:campaign_id] = {formula: "(data -> 'campaign_id')::bigint", type: 'integer'}
	FIELD[:impressions] = {formula: "(data -> 'impressions')::integer", type: 'integer'}
	FIELD[:app_installs] = {formula: "(data -> 'app_installs')::integer", type: 'integer'}
	FIELD[:advert_set_id] = {formula: "(data -> 'advert_set_id')::bigint", type: 'integer'}
	FIELD[:unique_clicks] = {formula: "(data -> 'unique_clicks')::integer", type: 'integer'}
	FIELD[:website_clicks] = {formula: "(data -> 'website_clicks')::integer", type: 'integer'}
	FIELD[:page_engagement] = {formula: "(data -> 'page_engagement')::integer", type: 'integer'}
	FIELD[:post_engagement] = {formula: "(data -> 'post_engagement')::integer", type: 'integer'}
	FIELD[:advert_objective] = {formula: "data -> 'advert_objective'", type: 'string'}
	FIELD[:leads_conversion] = {formula: "(data -> 'leads_conversion')::integer", type: 'integer'}
	FIELD[:website_conversion] = {formula: "(data -> 'website_conversion')::integer", type: 'integer'}
	FIELD[:click_through_rate_ctr] = {formula: "(data -> 'click_through_rate_ctr')::float", type: 'percentage'}
	FIELD[:cost_per_click_cpc_eur] = {formula: "(data -> 'cost_per_click_cpc_eur')::float", type: 'currency'}
	FIELD[:cost_per_page_like_eur] = {formula: "(data -> 'cost_per_page_like_eur')::float", type: 'currency'}
	FIELD[:mobile_app_installations] = {formula: "(data -> 'mobile_app_installations')::integer", type: 'integer'}
	FIELD[:cost_per_unique_click_eur] = {formula: "(data -> 'cost_per_unique_click_eur')::float", type: 'currency'}
	FIELD[:cost_per_website_click_eur] = {formula: "(data -> 'cost_per_website_click_eur')::float", type: 'currency'}
	FIELD[:cost_per_lead_conversion_eur] = {formula: "(data -> 'cost_per_lead_conversion_eur')::float", type: 'currency'}
	FIELD[:cost_per_page_engagement_eur] = {formula: "(data -> 'cost_per_page_engagement_eur')::float", type: 'currency'}
	FIELD[:cost_per_post_engagement_eur] = {formula: "(data -> 'cost_per_post_engagement_eur')::float", type: 'currency'}
	FIELD[:cost_per_app_installation_eur] = {formula: "(data -> 'cost_per_app_installation_eur')::float", type: 'currency'}
	FIELD[:cost_per_1000_people_reached_eur] = {formula: "(data -> 'cost_per_1000_people_reached_eur')::float", type: 'currency'}
	FIELD[:cost_per_website_conversion_eur] = {formula: "(data -> 'cost_per_website_conversion_eur')::float", type: 'currency'}
	FIELD[:unique_click_through_rate_u_ctr] = {formula: "(data -> 'unique_click_through_rate_u_ctr')::float", type: 'percentage'}
	FIELD[:cost_per_1000_impressions_cpm_eur] = {formula: "(data -> 'cost_per_1000_impressions_cpm_eur')::float", type: 'currency'}
	FIELD[:cost_per_checkout_conversion_eur] = {formula: "(data -> 'cost_per_checkout_conversion_eur')::float", type: 'currency'}
	FIELD[:cost_per_mobile_app_installation_eur] = {formula: "(data -> 'cost_per_mobile_app_installation_eur')::float", type: 'currency'}

	REPORT_FIELDS = {
		'ID01' => [
			:start_date,
			:end_date,
			:campaign,
			:spend_eur,
			:reach,
			:frequency,
			:cost_per_1000_people_reached_eur,
			:clicks,
			:unique_clicks,
			:click_through_rate_ctr,
			:unique_click_through_rate_u_ctr,
			:cost_per_click_cpc_eur,
			:cost_per_website_click_eur,
			:cost_per_checkout_conversion_eur,
			:cost_per_lead_conversion_eur,
			:advert_set,
			:advert,
			:age,
			:gender,
			:impressions,
			:cost_per_1000_impressions_cpm_eur,
			:cost_per_unique_click_eur,
			:website_conversion,
			:leads_conversion,
			:cost_per_website_conversion_eur,
			:advert_objective,
			:website_clicks,
			:page_likes,
			:page_engagement,
			:post_engagement,
			:app_installs,
			:mobile_app_installations,
			:cost_per_page_like_eur,
			:cost_per_page_engagement_eur,
			:cost_per_post_engagement_eur,
			:cost_per_app_installation_eur,
			:cost_per_mobile_app_installation_eur,
			:advert_set_id,
			:advert_id,
			:campaign_id,
			:account_id
		]
	}

	scope :all_fields, -> (report_tag = nil) do
		select "records.id, " + REPORT_FIELDS[report_tag].map {|field_name| "#{FIELD[field_name][:formula]} as #{field_name}"}.join(', ')
	end

	scope :sort_by, -> (params_order) do
		params_order ||= {}
    params_order[:by] ||= 'start_date'
    params_order[:direction] ||= 'desc'

    order("#{params_order[:by]} #{params_order[:direction]}, records.id #{params_order[:direction]}")
	end

	def self.fields
		Record::FIELD.map(&:first)
	end
end
