# encoding: utf-8
class DailyReport < ActiveRecord::Base
  after_save :upload_data_to_google_analytics

  private

  def upload_data_to_google_analytics
    DataUpload::Daily.upload!(self.body)
  end

end
