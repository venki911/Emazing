class AddAliasToGaAccounts < ActiveRecord::Migration
  def change
    add_column :ga_accounts, :alias, :string
  end
end
