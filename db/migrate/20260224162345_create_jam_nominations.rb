class CreateJamNominations < ActiveRecord::Migration[8.0]
  def change
    create_table :jam_nominations do |t|
      t.references :jam, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :method, null: false, default: 0 # manual / audience_based
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :jam_nominations, [:jam_id, :position], if_not_exists: true
  end
end