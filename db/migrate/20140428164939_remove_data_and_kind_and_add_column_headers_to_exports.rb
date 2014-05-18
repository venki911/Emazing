class RemoveDataAndKindAndAddColumnHeadersToExports < ActiveRecord::Migration
  def change
    add_column :ga_exports, :column_headers, :hstore
    remove_column :ga_exports, :data
    remove_column :ga_exports, :kind
  end
end
