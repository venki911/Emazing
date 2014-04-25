require "google/api_client"

class GaExportsController < ApplicationController
  # GET /ga_exports
  # GET /ga_exports.json
  def index
    @start_date = params['start-date'] || '2014-04-24'
    @end_date = params['end-date'] || '2014-04-24'

    @client = Google::APIClient.new(application_name: 'Emazing orodje',application_version: '1.0.0')
    @client.authorization = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: 'https://www.googleapis.com/auth/analytics',
      audience: 'https://accounts.google.com/o/oauth2/token',
      issuer: '649902570085@developer.gserviceaccount.com',
      signing_key: Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.secrets.google_account_certificate_path, 'notasecret')
    )
    @client.authorization.fetch_access_token!
    @analytics = @client.discovered_api('analytics', 'v3')

    results = @client.execute(api_method: @analytics.data.ga.get, :parameters => {
      'ids' => "ga:72057961",
      'start-date' => @start_date,
      'end-date' => @end_date,
      'dimensions' => "ga:source,ga:campaign,ga:medium,ga:adContent,ga:keyword",
      'metrics' => "ga:adCost,ga:adClicks,ga:itemQuantity,ga:transactionRevenue,ga:transactions",
      'sort' => "-ga:transactions,-ga:adCost,-ga:transactionRevenue",
      'max-results' => "10000"
    })

    @export_data = {}

    respond_to do |format|
      format.html do
        @export_data[:column_headers] = results.data.column_headers.map(&:name)
        @export_data[:rows] = results.data.rows
      end
      format.xlsx do
        @export_data[:column_headers] = ["Account", "Start Date", "End Date"] + results.data.column_headers.map(&:name)
        results_data_rows_with_account_and_dates = results.data.rows.map {|row| ["SMANIA", @start_date, @end_date] + row}
        @export_data[:rows] = results_data_rows_with_account_and_dates

        render xlsx: 'index', filename: "smania-2014-04-24_2014-04-24.xlsx", disposition: 'attachment'
      end
    end
  end
end
