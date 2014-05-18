class RenameGaDataToData < ActiveRecord::Migration
  def change
  	rename_column :ga_exports, :ga_data, :data
  end
end
