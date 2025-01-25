class CreateJamContributors < ActiveRecord::Migration[8.0]
  def change
    create_table :jam_contributors do |t|
      t.integer :user_id
      t.integer :jam_id
      t.string :status
      t.boolean :is_host
      t.boolean :is_admin
      t.boolean :is_judge

      t.timestamps
    end
  end
end
