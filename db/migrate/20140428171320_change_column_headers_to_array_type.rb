class ChangeColumnHeadersToArrayType < ActiveRecord::Migration
  def change
  	remove_column :ga_exports, :column_headers
  	add_column :ga_exports, :column_headers, :text, array: true, null: false, default: []
  end
end
