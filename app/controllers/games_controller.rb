class GamesController < ApplicationController
  before_action :authenticate_user, only: [:new, :create, :edit, :update]
  before_action :root_check, only: [:edit, :update, :destroy]

  def new
  end

  def showcase
    @search_results = nil
    @tags = Tag.all
    if current_user
      @my_games = Game.where(author: current_user)
      @games_under_moderation = @my_games.where(status: 0)
      @games_accepted = @my_games.where(status: 1)
      @games_rejected = @my_games.where(status: 2)
    end

    if should_search?
      lower_case_search = "%#{params[:search].downcase}%"
      games = Game.where(status: 1)
      games = games.where("LOWER(games.name) LIKE ? OR LOWER(games.description) LIKE ?",
                          lower_case_search, lower_case_search)
      @pagy, @games = pagy(games, limit: 12)
    else
      @pagy, @games = pagy(Game.all.where(status: 1), limit: 12)
    end

    if params[:tag_ids].present?
      tag_ids = params[:tag_ids].map(&:to_i)
      if params[:tag_mode] == 'any'
        @games = @games.joins(:tags).where(tags: { id: tag_ids }).distinct
      else
        @games = @games.joins(:tags).group('games.id').having('array_agg(tags.id) @> ARRAY[?]::bigint[]', tag_ids)
      end
    end

    respond_to do |format|
      format.html
      format.turbo_stream { @search_results = should_search? ? @games : nil }
    end
  end

  def show
    @game = Game.find(params[:id])
    if @game.status != 1 && current_user != @game.author
      flash[:failure] = "Игра находится на модерации"
      redirect_to dashboard_path
    end
  end

  def create
    @game = Game.new(game_params.merge(author: current_user))
    @tags = Tag.all
    if @game.save
      admins = User.where(role: 2)
      admins.each do |admin|
        current_user.create_notification(admin, current_user, 'awaiting game moderation', @game)
      end
      flash[:success] = "Игра отправлена на модерацию!"
      redirect_to game_profile_path
    else
      flash[:failure] = @game.errors.full_messages
      render :new, status: :see_other
    end
  rescue ActiveRecord::RecordNotUnique => e
    flash[:failure] = "Игра с таким названием уже существует."
    render :new, status: :see_other
  end

  def edit
    @game = current_user.games.find_by_id(params[:id])
    @tags = Tag.all
  end

  def update
    @game = current_user.games.find_by_id(params[:id])
    if @game.update(game_params)
      admins = User.where(role: 2)
      admins.each do |admin|
        current_user.create_notification(admin, current_user, 'awaiting game moderation', @game)
      end
      @game.update(status: 0)
      flash[:success] = "Игра обновлена и отправлена на повторную модерацию!"
      redirect_to game_profile_path
    else
      flash[:failure] = @game.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game = current_user.games.find_by_id(params[:id])
    if @game.destroy
      flash[:success] = 'Игра успешно удалена.'
    else
      flash[:failure] = "Something went wrong!"
    end
    redirect_to dashboard_path
  end

  private

  def root_check
    unless current_user.games.find_by_id(params[:id])
      flash[:failure] = "Недостаточно прав"
      redirect_to dashboard_path
    end
  end

  def game_params
    params.require(:game)
          .permit(:name, :description, :cover, :game_file, tag_ids: [])
  end

  def should_search?
    params[:search].present? && !params[:search].empty?
  end
end