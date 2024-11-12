class ChangeJamIdInRatingsToNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :ratings, :jam_id, true
  end
end
