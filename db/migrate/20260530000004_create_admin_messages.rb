class CreateAdminMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_messages do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
