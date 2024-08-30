class CreateJams < ActiveRecord::Migration[7.1]
  def change
    create_table :jams do |t|
      t.string :name
      t.integer :author_id

      t.timestamps
    end
    add_index :jams, :name
    add_index :jams, :author_id
  end
end
