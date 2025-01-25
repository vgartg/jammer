class RemoveAddedTimeFromContributors < ActiveRecord::Migration[8.0]
  def change
    remove_column :jam_contributors, :added_at, :datetime
  end
end
