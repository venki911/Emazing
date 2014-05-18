class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_current_ga_account
  before_filter :authenticate

  def set_current_ga_account
  	@current_ga_account = GaAccount.find_by alias: "www.medex.si"
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "adman" && password == "m4dman"
    end
  end
end
