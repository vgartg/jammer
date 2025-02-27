class AddReasonToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :reason, :string
  end
end
