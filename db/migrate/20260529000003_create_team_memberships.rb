class CreateTeamMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :team_memberships do |t|
      t.integer :team_id, null: false
      t.integer :user_id, null: false
      t.string :role, null: false, default: 'member'
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :team_memberships, :team_id
    add_index :team_memberships, :user_id
    add_index :team_memberships, %i[team_id user_id], unique: true
  end
end
