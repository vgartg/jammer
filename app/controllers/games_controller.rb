class GamesController < ApplicationController
  before_action :authenticate_user, only: [:new, :create, :edit, :update]
  def new

  end

  def showcase
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id])
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      puts 'Игра создана:'
      puts @game
      redirect_to dashboard_path
    else
      puts 'Игра не создана'
      flash[:errors] = @game.errors.full_messages
      render :new, status: :see_other
    end
  end

  def edit
    @game = Game.find_by_id(params[:id])
  end

  def update
    @game = Game.find(params[:id])
    if @game.update(game_params)
      redirect_to game_profile_path, notice: 'Игра успешно обновлена'
    else
      flash[:errors] = @game.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def game_params
    link = '/users/' + session[:current_user].to_s
    params.require(:game)
      .permit(:name, :description, :cover)
      .merge(author_link: link)
  end
end