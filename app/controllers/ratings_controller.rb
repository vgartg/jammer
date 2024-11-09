class RatingsController < ApplicationController
  def create
    @game = Game.find(params[:game_id])

    # Создаем или находим рейтинг игры
    @rating = @game.rating || @game.create_rating(average_rating: 0.0)

    # Создаем или обновляем отзыв с пользовательской оценкой и комментарием
    @review = @game.reviews.find_or_initialize_by(user: current_user)

    # Проверка, если рейтинг или комментарий отсутствует
    if params[:rating][:user_mark].to_i > 0 || params[:rating][:criterion].present?
      @review.user_mark = params[:rating][:user_mark].to_i
      @review.criterion = params[:rating][:criterion]
      @review.save
    end

    # Обновляем средний рейтинг игры
    Rating.update_average_rating(@game)

    redirect_to game_path(@game)
  end
end
