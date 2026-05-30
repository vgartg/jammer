class CreateUserAchievements < ActiveRecord::Migration[8.0]
  def change
    create_table :user_achievements do |t|
      t.integer :user_id, null: false
      t.string :achievement_key, null: false
      t.datetime :earned_at, null: false

      t.timestamps
    end

    add_index :user_achievements, :user_id
    add_index :user_achievements, %i[user_id achievement_key], unique: true
  end
end
