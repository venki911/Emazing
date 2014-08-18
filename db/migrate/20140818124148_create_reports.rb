class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
    	t.string :source_name
    	t.string :tag
    end
  end
end
