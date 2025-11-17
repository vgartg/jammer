class AddUserMarkToRatings < ActiveRecord::Migration[8.0]
  def change
    add_column :ratings, :user_mark, :integer
  end
end
