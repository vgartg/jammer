class AddJuriesIdToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :juriesId, :bigint, array:true, default: []
  end
end
