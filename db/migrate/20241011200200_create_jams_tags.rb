class CreateJamsTags < ActiveRecord::Migration[7.1]
  def change
    create_table :jams_tags do |t|
      t.references :jam, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
