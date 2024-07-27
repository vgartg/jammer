class CreateGamesTags < ActiveRecord::Migration[7.1]
  def change
    create_table :games_tags do |t|
      t.references :game, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
