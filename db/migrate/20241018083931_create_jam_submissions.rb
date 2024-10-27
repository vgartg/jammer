class CreateJamSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :jam_submissions do |t|
      t.integer :jam_id
      t.integer :game_id
      t.timestamp :submitted_at

      t.timestamps
    end
  end
end
