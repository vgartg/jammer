class AddFrozenReasonToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :frozen_reason, :string
  end
end
