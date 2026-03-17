class AddCommentToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :comment, :text
  end
end