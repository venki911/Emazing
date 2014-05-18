require "google/api_client"

class GaExportsController < ApplicationController
  # GET /ga_exports
  # GET /ga_exports.json
  def index
    @ga_exports = GaExport.where(profile_id: @current_ga_account.profile_id).order('start_date DESC').includes(:ga_records)

    respond_to do |format|
      format.html
      format.xlsx do
        render xlsx: 'index', filename: "#{@current_ga_account.alias}-#{Date.current}.xlsx", disposition: 'attachment'
      end
    end
  end

  def update
    @ga_export = GaExport.find(params[:id])

    if @ga_export.export_data_from_ga
      redirect_to ga_exports_url
    else
      render text: "Uvoz neuspešen, pojdi nazaj in poskusi ponovno!"
    end
  end
end
