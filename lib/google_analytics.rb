require "google/api_client"
require "csv"

module GoogleAnalytics
  class CustomData
    def self.upload!(string_io, recorded_at, account_id, custom_data_source_id, web_property_id)
      # I. authenticate with google
      @client = Google::APIClient.new(application_name: 'Emazing orodje',application_version: '1.0.0')

      key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.secrets.google_account_certificate_path, 'notasecret')
      @client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/analytics',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :issuer => '649902570085@developer.gserviceaccount.com',
        :signing_key => key)

      @client.authorization.fetch_access_token!
      @analytics = @client.discovered_api('analytics', 'v3')

      Google::APIClient.logger.level = Logger::DEBUG

      # II. upload data
      method = @analytics.management.daily_uploads.upload
      media = Google::APIClient::UploadIO.new(string_io, 'text/csv')
      params = {
        'uploadType' => 'media',
        'accountId' => account_id,
        "appendNumber" => 1,
        "customDataSourceId" => custom_data_source_id,
        "date" => recorded_at,
        "type" => 'cost',
        "webPropertyId" => web_property_id,
        "reset" => true
      }
      results = @client.execute(api_method: method, parameters: params, headers: {'Content-Length' => media.length.to_s, 'Content-Type' => 'application/octet-stream'}, body: media)

      # III. print results
      puts JSON.parse(results.body)
    end
  end

  class Reports
    def self.export(profile_id, date)
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

      Google::APIClient.logger.level = Logger::DEBUG

      results = @client.execute(api_method: @analytics.data.ga.get, :parameters => {
        'ids' => "ga:#{profile_id}",
        'start-date' => date,
        'end-date' => date,
        'dimensions' => "ga:source,ga:campaign,ga:medium,ga:adContent,ga:keyword",
        'metrics' => "ga:adCost,ga:adClicks,ga:sessions,ga:itemQuantity,ga:transactionRevenue,ga:transactions",
        'sort' => "-ga:transactions,-ga:adCost,-ga:transactionRevenue",
        'max-results' => "10000"
      })

      results
    end
  end
end
