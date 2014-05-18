class RenameGaAccountViewIdToProfileId < ActiveRecord::Migration
  def change
  	rename_column :ga_accounts, :view_id, :profile_id
  end
end
