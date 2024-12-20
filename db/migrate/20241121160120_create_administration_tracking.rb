class CreateAdministrationTracking < ActiveRecord::Migration[8.0]
  def change
    create_table :administration_tracking do |t|
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.string :structure_type, null: false
      t.bigint :structure_id, null: false
      t.json :changed_fields, null: false
      t.timestamps
    end

    add_index :administration_tracking, %i[admin_id structure_type structure_id]
  end
end
