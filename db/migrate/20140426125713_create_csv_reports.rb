class CreateCsvReports < ActiveRecord::Migration
  def change
    create_table :csv_reports do |t|
      t.date :recorded_at
      t.text :source
      t.string :facebook_ads_account_id
      t.timestamps
    end
  end
end
