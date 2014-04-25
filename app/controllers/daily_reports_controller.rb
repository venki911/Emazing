class DailyReportsController < ApplicationController
  protect_from_forgery except: [:create]

  def new
    @daily_report = DailyReport.new
  end

  def create
    @daily_report = DailyReport.new
    @daily_report.body = File.read(params[:daily_report][:body].tempfile).force_encoding("UTF-8")
    @daily_report.created_at = params[:daily_report][:created_at]

    if @daily_report.save
      render text: "Upload successfull! Go to Google Analytics."
    else
      render text: "Err, something went wrong."
    end
  end

end
