class AddListOfGamesToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :games, :integer, array: true, default: []
  end
end
