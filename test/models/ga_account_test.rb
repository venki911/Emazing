require 'test_helper'
require "google/api_client"

class GaAccountTest < ActiveSupport::TestCase
  test "preveri ali deluje povezava z google analytics" do
    # http://ga-dev-tools.appspot.com/explorer/?dimensions=ga%3Asource%2Cga%3Acampaign%2Cga%3Amedium%2Cga%3AadContent%2Cga%3Akeyword&metrics=ga%3AitemQuantity%2Cga%3AadCost%2Cga%3AadClicks%2Cga%3AtransactionRevenue%2Cga%3Atransactions&sort=-ga%3Atransactions%2C-ga%3AadCost%2C-ga%3AtransactionRevenue&start-date=2014-04-24&end-date=2014-04-24&max-results=1000
    @client = Google::APIClient.new(application_name: 'Emazing orodje',application_version: '1.0.0')

    key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.secrets.google_account_certificate_path, 'notasecret')
    @client.authorization = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: 'https://www.googleapis.com/auth/analytics',
      audience: 'https://accounts.google.com/o/oauth2/token',
      issuer: '649902570085@developer.gserviceaccount.com',
      signing_key: key
    )

    @client.authorization.fetch_access_token!
    @analytics = @client.discovered_api('analytics', 'v3')

    startDate = DateTime.now.prev_month.strftime("%Y-%m-%d")
    endDate = DateTime.now.strftime("%Y-%m-%d")
    profileID = '69872256' # 69872256: medex

    results = @client.execute(api_method: @analytics.data.ga.get, :parameters => {
      'ids' => "ga:69872256",
      'start-date' => "2014-04-24",
      'end-date' => "2014-04-24",
      'dimensions' => "ga:source,ga:campaign,ga:medium,ga:adContent",
      'metrics' => "ga:itemQuantity,ga:adCost,ga:adClicks,ga:transactionRevenue,ga:transactions",
      'filters' => "ga:transactions!=0",
      'sort' => "-ga:transactions"
    })

    column_headers = results.data.column_headers.map(&:name)
    rows = results.data.rows


    @client.execute(api_method: @analytics.management.accounts.list)
  end

  test "izpisi seznam daily uploads" do
    @client = Google::APIClient.new(application_name: 'Emazing orodje',application_version: '1.0.0')

    key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.secrets.google_account_certificate_path, 'notasecret')
    @client.authorization = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: 'https://www.googleapis.com/auth/analytics',
      audience: 'https://accounts.google.com/o/oauth2/token',
      issuer: '649902570085@developer.gserviceaccount.com',
      signing_key: key
    )

    @client.authorization.fetch_access_token!
    @analytics = @client.discovered_api('analytics', 'v3')

    method = @analytics.management.daily_uploads.list
    params = {
      'accountId' => @medex_params[:account_id],
      "customDataSourceId" => @medex_params[:customDataSourceId],
      "end-date" => "2014-04-24",
      "start-date" => "2014-04-20",
      "type" => 'cost',
      "webPropertyId" => @medex_params[:webPropertyId]
    }
    results = @client.execute(api_method: method, parameters: params)
    puts JSON.parse(results.body)
  end

  test "izbrisi daily uploads za dolocen datum" do
    @client = Google::APIClient.new(application_name: 'Emazing orodje',application_version: '1.0.0')

    key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.secrets.google_account_certificate_path, 'notasecret')
    @client.authorization = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: 'https://www.googleapis.com/auth/analytics',
      audience: 'https://accounts.google.com/o/oauth2/token',
      issuer: '649902570085@developer.gserviceaccount.com',
      signing_key: key
    )

    @client.authorization.fetch_access_token!
    @analytics = @client.discovered_api('analytics', 'v3')
    
    method = @analytics.management.daily_uploads.delete
    params = {
      'accountId' => @medex_params[:account_id],
      "customDataSourceId" => @medex_params[:customDataSourceId],
      "date" => "2014-04-24",
      "type" => 'cost',
      "webPropertyId" => @medex_params[:webPropertyId]
    }
    results = @client.execute(api_method: method, parameters: params)
    puts JSON.parse(results.body)
  end
end
