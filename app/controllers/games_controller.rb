class GamesController < ApplicationController
  before_action :authenticate_user, only: [:new, :create, :edit, :update]

  def new
    @notifications = current_user.notifications
    @game = Game.new
  end

  def showcase
    @search_results = nil
    @tags = Tag.all
    if current_user
      @notifications = current_user.notifications
    end

    if should_search?
      lower_case_search = "%#{params[:search].downcase}%"
      @games = Game.where("LOWER(games.name) LIKE ? OR LOWER(games.description) LIKE ?",
                          lower_case_search, lower_case_search)
    else
      @games = Game.all
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
    if current_user
      @notifications = current_user.notifications
    end
  end

  def submit
    # Check if the submission already exists
    #existing_submission = JamSubmission.find_by(game_id: params[:game_id], jam_id: params[:jam_id])

    #unless existing_submission
    #  @submission = JamSubmission.create(submission_params)
    #end
    submission = JamSubmission.where(jam_id: params[:jam_id]).find_by(user_id: current_user.id)
    submission.update(game_id: params[:game_id])
    redirect_to
  end

  def create
    @game = Game.new(game_params.merge(author: current_user))
    @tags = Tag.all
    if @game.save
      flash[:success] ||= []
      flash[:success] << "Игра успешно создана!"
      redirect_to games_showcase_path
    else
      flash[:failure] ||= []
      flash[:failure].concat(@game.errors.full_messages)
      render :new, status: :see_other
    end
  rescue ActiveRecord::RecordNotUnique => e
    flash[:failure] ||= []
    flash[:failure] << "Игра с таким названием уже существует."
    render :new, status: :see_other
  end

  def edit
    @tags = Tag.all
    @game = Game.find(params[:id])
  end

  def update
    @game = current_user.games.find_by_id(params[:id])
    if @game.update(game_params)
      flash[:success] ||= []
      flash[:success] << "Игра успешно обновлена."
      redirect_to game_profile_path
    else
      flash[:failure] ||= []
      flash[:failure].concat(@game.errors.full_messages)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game = current_user.games.find_by_id(params[:id])
    if @game.destroy
      flash[:success] ||= []
      flash[:success] << 'Игра успешно удалена.'
    else
      flash[:failure] ||= []
      flash[:failure] << "Something went wrong!"
    end
    redirect_to dashboard_path
  end

  private

  def game_params
    params.require(:game)
          .permit(:name, :description, :cover, :game_file, tag_ids: [])
  end

  def submission_params
    params
      .permit(:game_id, :jam_id, :user_id)
  end

  def should_search?
    params[:search].present? && !params[:search].empty?
  end
end