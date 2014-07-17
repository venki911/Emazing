class RemoveDailyReports < ActiveRecord::Migration
	def up
		drop_table :daily_reports
	end
  def down

  end
end
