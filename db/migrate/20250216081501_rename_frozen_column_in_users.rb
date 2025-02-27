class RenameFrozenColumnInUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :frozen, :is_frozen
  end
end
