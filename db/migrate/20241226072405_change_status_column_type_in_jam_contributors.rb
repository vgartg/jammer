class ChangeStatusColumnTypeInJamContributors < ActiveRecord::Migration[8.0]
  def change
    change_column :jam_contributors, :status, :boolean, default: true, null: false, using: 'status::boolean'
  end
end
