class AddLeaderInvitedToTeamMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :team_memberships, :leader_invited, :boolean, default: false, null: false
  end
end
