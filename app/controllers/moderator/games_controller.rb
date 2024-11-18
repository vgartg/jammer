module Moderator
  class GamesController < ApplicationController
    before_action :moderator?
    before_action :set_game!, only: %i[edit update destroy]

    def index
      games = search_games(Game.all)
      games = sort_games(games)
      @pagy, @games = pagy(games, limit: 10)
    end

    def edit
      @game = Game.find(params[:id])
    end

    def update
      old_status = @game.status
      if @game.update(game_params)
        flash[:success] = 'Игра успешно обновлена'
        if old_status != @game.status
          @author = @game.author
          @author.create_notification(@author, current_user, 'game change status after moderation', @game)
        end
      else
        flash[:failure] = @game.errors.full_messages
      end
      redirect_to request.fullpath
    end

    def destroy
      @game.destroy
      flash[:success] = 'Игра успешно удалена'
      redirect_to moderators_games_path
    end

    private

    def set_game!
      @game = Game.find params[:id]
    end

    def sort_games(games)
      sortable_columns = %w[id author_id name status created_at]
      sort_by = sortable_columns.include?(params[:sort_by]) ? params[:sort_by] : 'id'
      direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      games.order("#{sort_by} #{direction}")
    end

    def search_games(games)
      if params[:query].present?
        query = params[:query].strip.downcase

        if query.to_i.to_s == query
          games = games.where("games.id = :query OR games.status = :query", query: query.to_i)
        else
          games = games.joins(:author).where("games.name ILIKE :query OR games.created_at::TEXT ILIKE :query OR users.name ILIKE :query", query: "%#{query}%")
        end
      end

      games
    end

    def game_params
      params.require(:game)
            .permit(:name, :description, :cover, :status, :game_file, tag_ids: []).merge(moderator_edit: true)
    end
  end
end