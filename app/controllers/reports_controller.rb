class ReportsController < ApplicationController
  def index
  	@report_tag = 'ID01'
  	respond_to do |format|
      format.html { @records = nil }
      format.json { @records = Record.all_fields(@report_tag) }
      # format.xlsx do
      #   render xlsx: 'index', filename: "#{@current_ga_account.alias}-#{Date.current}.xlsx", disposition: 'attachment'
      # end
    end
  end
end
