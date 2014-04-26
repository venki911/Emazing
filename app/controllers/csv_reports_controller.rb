class CsvReportsController < ApplicationController
  def index
  	@csv_reports = CsvReport.all
  end
end
