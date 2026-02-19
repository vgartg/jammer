class GamesController < ApplicationController
  before_action :authenticate_user, only: %i[new create edit update]
  before_action :root_check, only: %i[edit update destroy]

  def new
    @notifications = current_user.notifications
    @game = Game.new
  end

  def showcase
    @search_results = nil
    @tags = Tag.all

    if should_search?
      lower_case_search = "%#{params[:search].downcase}%"
      games = Game.where(status: 1)
      games = games.where('LOWER(games.name) LIKE ? OR LOWER(games.description) LIKE ?',
                          lower_case_search, lower_case_search)
      @pagy, @games = pagy(games, limit: 12)
    else
      @pagy, @games = pagy(Game.all.where(status: 1), limit: 12)
    end

    if params[:tag_ids].present?
      tag_ids = params[:tag_ids].map(&:to_i)
      @games = if params[:tag_mode] == 'any'
                 @games.joins(:tags).where(tags: { id: tag_ids }).distinct
               else
                 @games.joins(:tags).group('games.id').having('array_agg(tags.id) @> ARRAY[?]::bigint[]', tag_ids)
               end
    end

    respond_to do |format|
      format.html
      format.turbo_stream { @search_results = should_search? ? @games : nil }
    end
  end

  def my_games
    authenticate_user

    @my_games = current_user.games
    @games_under_moderation = @my_games.where(status: 0)
    @games_accepted         = @my_games.where(status: 1)
    @games_rejected         = @my_games.where(status: 2)

    render partial: 'games/my_games', layout: false
  end

  def show
    @game = Game.find(params[:id])
    @jam_id = params[:jam_id]

    if @jam_id.blank?
      @rating = @game.ratings.find_by(jam_id: nil)
      @rating ||= @game.ratings.create(jam_id: nil, average_rating: 0.0)
      @review = @game.reviews.find_by(user: current_user, jam_id: nil) || @game.reviews.build(user: current_user, jam_id: nil)
      @reviews = @game.reviews.where(jam_id: nil).where.not(user_id: current_user.id)
    else
      @rating = @game.ratings.find_by(jam_id: @jam_id)
      @rating ||= @game.ratings.create(jam_id: @jam_id, average_rating: 0.0)
      @review = @game.reviews.find_by(user: current_user, jam_id: @jam_id) || @game.reviews.build(user: current_user, jam_id: @jam_id)
      @reviews = @game.reviews.where(jam_id: @jam_id).where.not(user_id: current_user.id)
    end

    if current_user
      @notifications = current_user.notifications
    end
    return unless @game.status != 1 && current_user != @game.author

    flash[:failure] = 'Игра находится на модерации'
    redirect_to dashboard_path
  end

  def submit
    # Check if the submission already exists
    # existing_submission = JamSubmission.find_by(game_id: params[:game_id], jam_id: params[:jam_id])

    # unless existing_submission
    #  @submission = JamSubmission.create(submission_params)
    # end
    submission = JamSubmission.where(jam_id: params[:jam_id]).find_by(user_id: current_user.id)
    submission.update(game_id: params[:game_id])
    redirect_to
  end

  def create
    @game = Game.new(game_params.merge(author: current_user))
    @tags = Tag.all
    if @game.save
      admins = User.where(role: [1, 2])
      admins.each do |admin|
        current_user.create_notification(admin, current_user, 'awaiting game moderation', @game)
      end
      flash[:success] ||= []
      flash[:success] << translate("games.create.success")
      redirect_to dashboard_path
    else
      flash[:failure] ||= []
      flash[:failure].concat(@game.errors.full_messages)
      render :new, status: :see_other
    end
  rescue ActiveRecord::RecordNotUnique => e
    flash[:failure] ||= []
    flash[:failure] << t('games.create.failure')
    render :new, status: :see_other
  end

  def edit
    @game = current_user.games.find_by_id(params[:id])
    @tags = Tag.all
    @game = Game.find(params[:id])
  end

  def update
    @game = current_user.games.find_by_id(params[:id])
    if @game.update(game_params)
      admins = User.where(role: [1, 2])
      admins.each do |admin|
        current_user.create_notification(admin, current_user, 'awaiting game moderation', @game)
      end
      @game.update(status: 0)
      flash[:success] ||= []
      flash[:success] << t('games.update.success')
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
      flash[:success] << t('games.destroy.success')
    else
      flash[:failure] ||= []
      flash[:failure] << t('games.destroy.failure')
    end
    redirect_to dashboard_path
  end

  private

  def root_check
    return if current_user.games.find_by_id(params[:id])

    flash[:failure] = 'Недостаточно прав'
    redirect_to dashboard_path
  end

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
