class CreateJamContributors < ActiveRecord::Migration[8.0]
  def change
    create_table :jam_contributors do |t|
      t.references :jam, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :status, null: false, default: "pending" # pending/accepted

      t.boolean :host, default: false, null: false
      t.boolean :admin, default: false, null: false
      t.boolean :judge, default: false, null: false

      t.timestamps
    end

    add_index :jam_contributors, [:jam_id, :user_id], unique: true, if_not_exists: true
  end
end