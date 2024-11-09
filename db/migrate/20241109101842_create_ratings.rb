class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.integer :game_id, null: false, index: true
      t.integer :jam_id, null: false, index: true
      t.float :average_rating, default: 0.0
      t.timestamps
    end

  end
end
