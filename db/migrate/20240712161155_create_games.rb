class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :description, null: false
      t.string :author_link, null: false

      t.timestamps
    end
  end
end
