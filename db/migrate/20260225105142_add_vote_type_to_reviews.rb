class AddVoteTypeToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :vote_type, :integer, null: false, default: 0
    add_index :reviews, :vote_type

    # Чтобы один юзер не мог наставить дублей по одному критерию:
    add_index :reviews,
              [:user_id, :game_id, :jam_id, :criterion, :vote_type],
              unique: true,
              name: "index_reviews_unique_per_criterion_vote_type",
              if_not_exists: true
  end
end