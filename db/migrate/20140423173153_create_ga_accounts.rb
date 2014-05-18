class CreateGaAccounts < ActiveRecord::Migration
  def change
    create_table :ga_accounts do |t|
      t.string :account_id
      t.string :custom_data_source_id
      t.string :web_property_id
      t.string :profile_id

      t.timestamps
    end
  end
end
