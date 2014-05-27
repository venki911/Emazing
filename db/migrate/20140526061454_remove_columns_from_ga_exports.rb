class RemoveColumnsFromGaExports < ActiveRecord::Migration
  def change
  	remove_column :ga_exports, :column_headers
  end
end
