class AddAdminsIdToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :adminsId, :bigint, array:true, default: []
  end
end
