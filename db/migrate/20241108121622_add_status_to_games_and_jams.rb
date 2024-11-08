class AddStatusToGamesAndJams < ActiveRecord::Migration[8.0]
  def change
    # 0 - на модерации, 1 - принято модератором, 2 - отклонено модератором
    add_column :games, :status, :integer, :default => 0
    add_column :jams, :status, :integer, :default => 0
  end
end
