class CreateJamRatingSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :jam_rating_settings do |t|
      t.references :jam, null: false, foreign_key: true

      t.boolean :jury_enabled, null: false, default: true
      t.boolean :audience_enabled, null: false, default: true

      t.boolean :locked, null: false, default: false

      t.timestamps
    end

    add_index :jam_rating_settings, :jam_id, unique: true, if_not_exists: true
  end
end