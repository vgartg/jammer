class DeleteColumnUpdatedAtFromStatisticForDays < ActiveRecord::Migration[8.0]
  def change
    remove_column :statistic_for_days, :updated_at, :datetime
  end
end
