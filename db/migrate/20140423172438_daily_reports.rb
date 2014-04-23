class DailyReports < ActiveRecord::Migration
  def change
    create_table :daily_reports do |t|
      t.date :created_at
      t.text :body
    end
  end
end
