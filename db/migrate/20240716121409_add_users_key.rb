class AddUsersKey < ActiveRecord::Migration[7.1]
  def change
    remove_column :games, :author_link
    add_column :games, :author_id, :integer
    add_foreign_key :games, :users, column: :author_id, primary_key: :id
  end
end
