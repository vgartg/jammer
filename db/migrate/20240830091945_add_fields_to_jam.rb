class AddFieldsToJam < ActiveRecord::Migration[7.1]
  def change
    add_column :jams, :start_date, :date
    add_column :jams, :deadline, :date
    add_column :jams, :end_date, :date
    add_column :jams, :cover, :binary
    add_column :jams, :logo, :binary
  end
end
