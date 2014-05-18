class CreateGaRecords < ActiveRecord::Migration
  def change
    create_table :ga_records do |t|
      t.integer :ga_export_id
      t.text :data, array: true, null: false, default: []

      t.timestamps
    end
  end
end
