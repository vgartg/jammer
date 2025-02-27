class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.string :reportable_type, null: false
      t.integer :reportable_id, null: false
      t.string :reason, null: false
      t.text :comment
      t.integer :status, default: 0 # 0 = Pending, 1 = Resolved, 2 = Rejected

      t.timestamps
    end
  end
end
