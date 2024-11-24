class AddHostsIdToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :hostsId, :bigint, array:true, default: []
  end
end
