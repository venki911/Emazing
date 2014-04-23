require "google/api_client"
require "csv"

module DataUpload
  ga_account = GaAccount.first
  @smania_params = {account_id: ga_account.account_id, customDataSourceId: ga_account.custom_data_source_id, webPropertyId: ga_account.web_property_id, viewId: ga_account.view_id}
  @google_account = GoogleAccount.first

  class Daily
    def self.upload!(data)
      @client = Google::APIClient.new(application_name: 'Emazing orodje',application_version: '1.0.0')

      key = Google::APIClient::KeyUtils.load_from_pkcs12('/Users/tomazzlender/Code/emazing/65124e262941ef45c4f06a9f1189b9fc5db89a69-privatekey.p12', 'notasecret')
      @client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/analytics',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :issuer => '188678993551@developer.gserviceaccount.com',
        :signing_key => key)

      @client.authorization.fetch_access_token!
      @analytics = @client.discovered_api('analytics', 'v3')

      Google::APIClient.logger.level = Logger::DEBUG

      smania_rows = []
      date = nil

      CSV.parse(data) do |row|
        next if row.first == 'Start Date' # skip first line

        date = row.first
        account, medium, campaign = row[2].split('|').map(&:strip)

        output = ['fb bsmart', medium, campaign, row[6], row[3], row[5], row[4]]
        case account.mb_chars.downcase.to_s
        when 'smania' then sm_rows << output
        end
      end

      headers = ["ga:source", "ga:medium", "ga:campaign", "ga:adContent", "ga:impressions", "ga:adClicks", "ga:adCost"]

      smania_csv = CSV.generate do |csv|
        csv << headers
        fs_rows.each do |row|
          csv << row
        end
      end
      smania_csv = StringIO.new(smania_csv)

      method = @analytics.management.daily_uploads.upload
      media = Google::APIClient::UploadIO.new(sm_csv, 'text/csv')
      params = {
        'uploadType' => 'media',
        'accountId' => @smania_params[:account_id],
        "appendNumber" => 1,
        "customDataSourceId" => @smania_params[:customDataSourceId],
        "date" => date,
        "type" => 'cost',
        "webPropertyId" => @smania_params[:webPropertyId],
        "reset" => true
      }

      results = @client.execute(api_method: method, parameters: params, headers: {'Content-Length' => media.length.to_s, 'Content-Type' => 'application/octet-stream'}, body: media)
      puts JSON.parse(results.body)
    end

    def generate_csv(rows, headers)
      csv = CSV.generate do |csv|
        csv << headers
        rows.each do |row|
          csv << row
        end
      end
      StringIO.new(csv)
    end

    def upload_to_analytics(account, date, io)
      method = @analytics.management.daily_uploads.upload
      media = Google::APIClient::UploadIO.new(io, 'text/csv')
      params = {
        'uploadType' => 'media',
        'accountId' => account[:account_id],
        "appendNumber" => 1,
        "customDataSourceId" => account[:customDataSourceId],
        "date" => date,
        "type" => 'cost',
        "webPropertyId" => account[:webPropertyId],
        "reset" => true
      }

      results = @client.execute(api_method: method, parameters: params, headers: {'Content-Length' => media.length.to_s, 'Content-Type' => 'application/octet-stream'}, body: media)
    end
  end
end