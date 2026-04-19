class GamesController < ApplicationController
  before_action :authenticate_user, only: %i[new create edit update submit]
  before_action :root_check, only: %i[edit update destroy]
  before_action :jam_submission_edit_check, only: %i[edit update]

  def new
    @notifications = current_user.notifications
    @game = Game.new
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

  def show
    @game = Game.find(params[:id])
    @jam_id = params[:jam_id]

    if @jam_id.blank?
      @rating = @game.ratings.find_by(jam_id: nil)
      @rating ||= @game.ratings.create(jam_id: nil, average_rating: 0.0)
      if current_user
        @review = @game.reviews.find_by(user: current_user, jam_id: nil) || @game.reviews.build(user: current_user, jam_id: nil)
      end
      reviews = @game.reviews.where(jam_id: nil)
      @reviews = current_user ? reviews.where.not(user_id: current_user.id) : reviews
    else
      @rating = @game.ratings.find_by(jam_id: @jam_id)
      @rating ||= @game.ratings.create(jam_id: @jam_id, average_rating: 0.0)
      reviews = @game.reviews.where(jam_id: @jam_id)
      @reviews = current_user ? reviews.where.not(user_id: current_user.id) : reviews

      @jam = Jam.find(@jam_id)

      @single_pick_criteria = @jam.jam_criteria.where(kind: "manually_ranked").order(:position, :id)
      criterion_ids = @single_pick_criteria.pluck(:id)

      @single_pick_counts = JamCriterionPick
                              .where(jam_id: @jam.id, game_id: @game.id, jam_criterion_id: criterion_ids)
                              .group(:jam_criterion_id)
                              .count
    end

    if current_user
      @notifications = current_user.notifications
    end
    return unless @game.status != 1 && current_user != @game.author

    flash[:failure] = 'Игра находится на модерации'
    redirect_to dashboard_path
  end

  def submit
    submission = JamSubmission.find_by(jam_id: params[:jam_id], user_id: current_user.id)
    unless submission
      flash[:failure] = "Вы не участвуете в этом джеме"
      return redirect_to jam_profile_path(params[:jam_id])
    end

    game = current_user.games.find_by(id: params[:id])
    unless game
      flash[:failure] = "Игра не найдена"
      return redirect_to jam_profile_path(params[:jam_id])
    end

    submission.update(game_id: game.id)
    redirect_to jam_profile_path(params[:jam_id])
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

  def jam_submission_edit_check
    submission = JamSubmission.find_by(game_id: params[:id], user_id: current_user.id)
    return unless submission

    jam = submission.jam
    return if jam.submission_open?

    flash[:failure] = "Приём работ завершён. Редактирование игры недоступно"
    redirect_to game_profile_path(params[:id], jam_id: jam.id)
  end
end
