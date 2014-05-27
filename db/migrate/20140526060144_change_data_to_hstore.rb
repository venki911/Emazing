class ChangeDataToHstore < ActiveRecord::Migration
  def up
  	remove_column :ga_records, :data
  	add_column :ga_records, :data, :hstore, default: {}

  	GaExport.all.each do |ga_export|
  		ga_export.export_data_from_ga
  	end
  end

  def down
  	
  end
end
