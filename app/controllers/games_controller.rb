class GamesController < ApplicationController
  before_action :authenticate_user
  def new

  end

  def showcase
    @games = Game.all
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

  private
  def game_params
    params.require(:game)
          .permit(:name, :description, :author_link)
  end
end