class AddOpenMembershipToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :open_membership, :boolean, default: true, null: false
  end
end
