class AddFrozenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :frozen, :boolean, default: false
    add_column :users, :frozen_at, :datetime
    add_column :users, :unfreeze_at, :datetime
  end
end
