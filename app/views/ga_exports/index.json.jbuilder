json.array!(@ga_exports) do |ga_export|
  json.extract! ga_export, :id, :profile_id, :start_date, :end_date, :ga_data, :kind
  json.url ga_export_url(ga_export, format: :json)
end
