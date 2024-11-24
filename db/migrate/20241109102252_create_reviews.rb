class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.integer :rating_id, null: false, index: true
      t.integer :user_id, null: false, index: true
      t.float :user_mark, null: false
      t.string :criterion
      t.timestamps
    end

  end
end
