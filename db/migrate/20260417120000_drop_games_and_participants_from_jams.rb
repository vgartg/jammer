class DropGamesAndParticipantsFromJams < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:jams, :participants)
      execute <<~SQL
        INSERT INTO jam_submissions (jam_id, user_id, created_at, updated_at)
        SELECT p.jam_id, p.user_id, NOW(), NOW()
        FROM (
          SELECT j.id AS jam_id, unnest(j.participants) AS user_id
          FROM jams j
          WHERE j.participants IS NOT NULL
            AND array_length(j.participants, 1) > 0
        ) p
        WHERE NOT EXISTS (
          SELECT 1 FROM jam_submissions js
          WHERE js.jam_id = p.jam_id AND js.user_id = p.user_id
        );
      SQL
    end

    remove_column :jams, :games if column_exists?(:jams, :games)
    remove_column :jams, :participants if column_exists?(:jams, :participants)
  end

  def down
    add_column :jams, :games, :integer, array: true, default: []
    add_column :jams, :participants, :integer, array: true, default: []
  end
end
