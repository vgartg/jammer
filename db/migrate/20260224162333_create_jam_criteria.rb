class CreateJamCriteria < ActiveRecord::Migration[8.0]
  def change
    create_table :jam_criteria do |t|
      t.references :jam, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :kind, null: false, default: 0 # voted_on / manually_ranked
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :jam_criteria, [:jam_id, :position], if_not_exists: true
  end
end