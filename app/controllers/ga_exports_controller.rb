class GaExportsController < ApplicationController
  # GET /ga_exports
  # GET /ga_exports.json
  def index
    @ga_records = GaRecord.with_calculated_attrs
                          .sort_by(params[:order])
                          .filter_by(params[:filter])
                          .daterange(params[:daterange])
                          .from_account(@current_ga_account)

    respond_to do |format|
      format.html { @ga_records = nil }
      format.json
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
