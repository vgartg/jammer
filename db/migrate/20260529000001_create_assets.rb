class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.string :title, null: false
      t.text :description
      t.string :category, null: false, default: 'other'
      t.integer :author_id, null: false
      t.integer :downloads_count, null: false, default: 0

      t.timestamps
    end

    add_index :assets, :author_id
    add_index :assets, :category
  end
end
