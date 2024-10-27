class RemoveSubmittedAtFromJamSubmissions < ActiveRecord::Migration[8.0]
  def change
    remove_column :jam_submissions, :submitted_at, :integer
  end
end
