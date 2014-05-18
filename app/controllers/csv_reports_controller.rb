class CsvReportsController < ApplicationController
  def index
  	@csv_reports = CsvReport.order("recorded_at DESC")
  end
end
