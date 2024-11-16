class AddListOfGamesToJams < ActiveRecord::Migration[6.0]
  def change
    add_column :jams, :games, :integer, array: true, default: [] unless column_exists?(:jams, :games)
  end
end
