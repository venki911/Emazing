require 'test_helper'

class GaAccountTest < ActiveSupport::TestCase
  test "preveri ali deluje povezava z google analytics" do
  	@client = Google::APIClient.new(application_name: 'Emazing orodje',application_version: '1.0.0')

		key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.application.secrets.google_account_certificate_path, 'notasecret')
		@client.authorization = Signet::OAuth2::Client.new(
		  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
		  :scope => 'https://www.googleapis.com/auth/analytics',
		  :audience => 'https://accounts.google.com/o/oauth2/token',
		  :issuer => '188678993551@developer.gserviceaccount.com',
		  :signing_key => key)

		@client.authorization.fetch_access_token!
		@analytics = @client.discovered_api('analytics', 'v3')

		startDate = DateTime.now.prev_month.strftime("%Y-%m-%d")
		endDate = DateTime.now.strftime("%Y-%m-%d")
		profileID = GaAccount.first.account_id

		@client.execute(api_method: @analytics.data.ga.get, :parameters => {
			'ids' => "ga:" + profileID, 
			'start-date' => startDate,
			'end-date' => endDate,
			'dimensions' => "ga:day,ga:month",
			'metrics' => "ga:visits",
			'sort' => "ga:month,ga:day"
		})
  end
end
