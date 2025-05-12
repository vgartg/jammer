class AddHtml5IdToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :html5_id, :string
  end
end
