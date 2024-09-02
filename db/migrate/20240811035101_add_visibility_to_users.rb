class AddVisibilityToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :visibility, :string, default: 'All'
  end
end
