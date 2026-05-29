class CreateAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements do |t|
      t.integer  :author_id, null: false
      t.string   :announcement_type, default: 'general', null: false
      t.string   :version
      t.string   :title_en, null: false
      t.string   :title_ru, null: false
      t.text     :body_en
      t.text     :body_ru
      t.boolean  :published, default: false, null: false
      t.datetime :published_at
      t.timestamps
    end
    add_index :announcements, :author_id
    add_index :announcements, :published
    add_index :announcements, :announcement_type
  end
end
