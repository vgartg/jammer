class AddReasonToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :reason, :string
  end
end
