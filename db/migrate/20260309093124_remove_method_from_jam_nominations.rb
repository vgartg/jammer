class RemoveMethodFromJamNominations < ActiveRecord::Migration[8.0]
  def change
    remove_column :jam_nominations, :method, :integer
  end
end