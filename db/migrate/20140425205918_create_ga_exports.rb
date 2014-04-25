class CreateGaExports < ActiveRecord::Migration
  def change
    create_table :ga_exports do |t|
      t.string :profile_id
      t.date :start_date
      t.date :end_date
      t.hstore :ga_data
      t.string :kind

      t.timestamps
    end
  end
end
