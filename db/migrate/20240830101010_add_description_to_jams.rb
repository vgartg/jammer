class AddDescriptionToJams < ActiveRecord::Migration[7.1]
  def change
    add_column :jams, :description, :string
  end
end
