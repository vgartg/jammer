class JamsController < ApplicationController
  before_action :authenticate_user, only: %i[new create edit update submit_game]
  before_action :root_check, only: %i[edit update destroy]

  def new
    @notifications = current_user.notifications
    @jam = Jam.new
  end

  def participate
    unless JamSubmission.where(jam_id: params[:id]).find_by(user_id: current_user.id).present?
      jsb = JamSubmission.new(game_id: nil, jam_id: params[:id], user: current_user)
      if jsb.save
        flash[:notice] = "Вы успешно присоединились к джему!"
      else
        flash[:alert] = "Произошла ошибка. Попробуйте еще раз."
      end
    end
    redirect_to jam_profile_path(params[:id])
  end

  def delete_project
    submission = JamSubmission.where(jam_id: params[:id]).find_by(user_id: current_user.id)
    submission.update(game_id: nil)
    redirect_to jam_profile_path(params[:id])
  end

  def show_projects
    @jam = Jam.find(params[:id])
    @tags = Tag.all
    jams_games = @jam.jam_submissions.and(JamSubmission.where.not(game_id: nil))
                              .map{|jsb| Game.find_by_id(jsb.game_id)}
    if should_search?
      lower_case_search = "%#{params[:search].downcase}%"
      @games = Game.where("LOWER(games.name) LIKE ? OR LOWER(games.description) LIKE ?",
                        lower_case_search, lower_case_search)
    else
      @games = jams_games
    end

    respond_to do |format|
      format.html
      format.turbo_stream { @search_results = should_search? ? @games : nil }
    end
  end

  def show_participants
    @jam = Jam.find(params[:id])
    @users = @jam.jam_submissions.map{|jsb| User.find_by_id(jsb.user_id)}
  end

  def showcase
    @search_results = nil
    @tags = Tag.all
    if current_user
      @my_jams = Jam.where(author: current_user)
      @jams_under_moderation = @my_jams.where(status: 0)
      @jams_accepted = @my_jams.where(status: 1)
      @jams_rejected = @my_jams.where(status: 2)
    end

    if should_search?
      lower_case_search = "%#{params[:search].downcase}%"
      jams = Jam.where(status: 1)
      jams = jams.where('LOWER(jams.name) LIKE ? OR LOWER(jams.description) LIKE ?',
                        lower_case_search, lower_case_search)
      @pagy, @jams = pagy(jams, limit: 12)
    else
      @pagy, @jams = pagy(Jam.all.where(status: 1), limit: 12)
    end

    if params[:tag_ids].present?
      tag_ids = params[:tag_ids].map(&:to_i)
      @jams = if params[:tag_mode] == 'any'
                @jams.joins(:tags).where(tags: { id: tag_ids }).distinct
              else
                @jams.joins(:tags).group('jams.id').having('array_agg(tags.id) @> ARRAY[?]::bigint[]', tag_ids)
              end
    end

    respond_to do |format|
      format.html
      format.turbo_stream { @search_results = should_search? ? @jams : nil }
    end
  end

  def show
    @jam = Jam.find(params[:id])
    @jsb = @jam && current_user ? @jam.jam_submissions.find_by(user_id: current_user.id) : nil
    @game = @jsb && @jsb.game_id ? Game.find_by_id(@jsb.game_id) : nil
    if current_user
      @notifications = current_user.notifications
    end
    return unless @jam.status != 1 && current_user != @jam.author

    flash[:failure] = 'Джем находится на модерации'
    redirect_to dashboard_path
  end

  def create
    @jam = Jam.new(jam_params.merge(author: current_user))
    @tags = Tag.all
    failures = invalid_date
    if failures.any?
      flash[:failure] ||= []
      failures.each do |problem|
        flash[:failure] << problem
      end
      render :new, status: :see_other
    elsif  @jam.save
      admins = User.where(role: [1, 2])
      admins.each do |admin|
        current_user.create_notification(admin, current_user, 'awaiting jam moderation', @jam)
      end
      flash[:success] ||= []
      flash[:success] << t('jams.create.success')
      redirect_to dashboard_path
    else
      flash[:failure] ||= []
      flash[:failure].concat(@jam.errors.full_messages)
      render :new, status: :see_other
    end
  rescue ActiveRecord::RecordNotUnique => e
    flash[:failure] ||= []
    flash[:failure] << t('jams.create.failure')
    render :new, status: :see_other
  end

  def edit
    @jam = current_user.jams.find_by_id(params[:id])
    @tags = Tag.all
  end

  def submit_game
    @game = Game.new
  end

  def create_submission
    @game = Game.new(game_params.merge(author: current_user))
    if @game.save
      #JamSubmission.new(game: @game, jam_id: params[:id], user: current_user).save

      submission = JamSubmission.where(jam_id: params[:id]).find_by(user_id: current_user.id)
      submission.update(game_id: @game.id)
      redirect_to jam_profile_path(params[:id])
    else
      redirect_to dashboard_path
    end
  end

  def update
    @jam = current_user.jams.find_by_id(params[:id])
    failures = invalid_date
    if failures.any?
      flash[:failure] ||= []
      failures.each do |problem|
        flash[:failure] << problem
      end
      render :new, status: :see_other
      elsif @jam.update(jam_params)
      admins = User.where(role: [1, 2])
      admins.each do |admin|
        current_user.create_notification(admin, current_user, 'awaiting jam moderation', @jam)
      end
      @jam.update(status: 0)
      flash[:success] = 'Джем обновлен и отправлен на повторную модерацию!'
      redirect_to jam_profile_path
    else
      flash[:failure] ||= []
      flash[:failure].concat(@jam.errors.full_messages)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @jam = current_user.jams.find_by_id(params[:id])
    if @jam.destroy
      flash[:success] ||= []
      flash[:success] << t('jams.destroy.success')
    else
      flash[:failure] ||= []
      flash[:failure] << t('jams.destroy.failure')
    end
    redirect_to :dashboard
  end

  private

  def root_check
    return if current_user.jams.find_by_id(params[:id])

    flash[:failure] = 'Недостаточно прав'
    redirect_to dashboard_path
  end

  def jam_params
    params.require(:jam)
          .permit(:name, :description, :start_date, :deadline, :end_date, :cover, :logo, :users_can_votes, tag_ids: [])
  end

  def should_search?
    params[:search].present? && !params[:search].empty?
  end

  def submission_params
    params
      .permit(:game_id, :jam_id, :user_id)
  end

  def game_params
    params.require(:game)
          .permit(:name, :description, :cover, :game_file, tag_ids: [])
  end

  def invalid_date
    failures = []
    startDate = Date.parse(params[:jam][:start_date])
    deadline = Date.parse(params[:jam][:deadline])
    endDate = Date.parse(params[:jam][:end_date])

    deadline < startDate ? failures.push("Дата сдачи работ не может быть раньше даты начала") : failures
    endDate < deadline ? failures.push("Дата окончания джема не может быть раньше даты сдачи работ") : failures
    startDate.year < 2000 ? failures.push("Некорректная дата начала джема") : failures
    deadline.year < 2000 ? failures.push("Некорректная дата сдачи работ") : failures
    endDate.year < 2000 ? failures.push("Некорректная дата окончания джема") : failures

    failures
  end
end
