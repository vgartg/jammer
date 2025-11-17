class ReviewsController < ApplicationController
  def destroy
    @review = Review.find(params[:id])
    @game = @review.game
    jam_id = @review.jam_id

    @review.destroy

    Rating.update_average_rating(@game, jam_id)

    redirect_to game_path(@game, jam_id: jam_id)
  end
end
