class RatingsController < ApplicationController
  def create
    @game = Game.find(params[:game_id])

    jam_id = params[:rating][:jam_id].presence

    @review = @game.reviews.find_or_initialize_by(user: current_user, jam_id: jam_id)
    @review.user_mark = params[:rating][:user_mark].to_f
    @review.criterion = params[:rating][:criterion]
    @review.game_id = @game.id
    @review.jam_id = jam_id

    if @review.save
      Rating.update_average_rating(@game, jam_id)
    end

    redirect_to game_path(@game, jam_id: jam_id)
  end
end
