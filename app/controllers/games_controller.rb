class GamesController < ApplicationController
  before_action :authenticate_user, only: [:new, :create, :edit, :update]
  def new

  end

  def showcase
    if params[:search].present?
      @games = Game.where("name LIKE ? OR description LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    else
      @games = Game.all
    end

    respond_to do |format|
      format.html # showcase.html.erb
      format.json { render json: @games } # Для AJAX запросов
    end
  end

  def show
    @game = Game.find(params[:id])
  end

  def create
    @game = Game.new(game_params.merge(author: current_user))
    if @game.save
      redirect_to dashboard_path
    else
      flash[:errors] = @game.errors.full_messages
      render :new, status: :see_other
    end
    rescue ActiveRecord::RecordNotUnique => e
      flash[:errors] = ["Игра с таким названием уже существует"]
      render :new, status: :see_other
  end

  def edit
    @game = current_user.games.find_by_id(params[:id])
  end

  def update
    @game = current_user.games.find_by_id(params[:id])
    if @game.update(game_params)
      redirect_to game_profile_path, notice: 'Игра успешно обновлена'
    else
      flash[:errors] = @game.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game = current_user.games.find_by_id(params[:id])
    @game.destroy
    redirect_to games_showcase_path
  end

  private
  def game_params
    params.require(:game)
      .permit(:name, :description, :cover)
  end
end