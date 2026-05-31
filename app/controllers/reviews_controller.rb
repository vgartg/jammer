class ReviewsController < ApplicationController
  before_action :authorize_destroy!, only: :destroy

  def destroy
    @review = Review.find(params[:id])
    @game = @review.game
    jam_id = @review.jam_id

    @review.destroy

    Rating.update_average_rating(@game, jam_id)

    if current_user&.role == 'admin'
      redirect_to edit_admin_game_path(@game), notice: t('controllers.reviews.deleted')
    else
      redirect_to game_path(@game, jam_id: jam_id)
    end
  end

  private

  def authorize_destroy!
    review = Review.find(params[:id])
    return if current_user && (current_user.role == 'admin' || review.user_id == current_user.id)

    flash[:failure] = t('controllers.application.insufficient_rights')
    redirect_to news_path
  end
end
