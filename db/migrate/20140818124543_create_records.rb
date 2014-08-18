class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.hstore :data, default: {}
      t.integer :report_id
    end
  end
end
