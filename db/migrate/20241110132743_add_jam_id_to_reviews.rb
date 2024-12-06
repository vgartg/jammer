class AddJamIdToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :jam_id, :integer
  end
end
