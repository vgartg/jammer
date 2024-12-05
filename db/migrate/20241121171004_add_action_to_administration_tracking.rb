class AddActionToAdministrationTracking < ActiveRecord::Migration[8.0]
  def change
    add_column :administration_tracking, :action, :string
  end
end
