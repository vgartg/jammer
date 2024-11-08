class JamsController < ApplicationController
  before_action :authenticate_user, only: [:new, :create, :edit, :update, :submit_game]

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
      @notifications = current_user.notifications
    end

    if should_search?
      lower_case_search = "%#{params[:search].downcase}%"
      @jams = Jam.where("LOWER(jams.name) LIKE ? OR LOWER(jams.description) LIKE ?",
                        lower_case_search, lower_case_search)
    else
      @jams = Jam.all
    end

    if params[:tag_ids].present?
      tag_ids = params[:tag_ids].map(&:to_i)
      if params[:tag_mode] == 'any'
        @jams = @jams.joins(:tags).where(tags: { id: tag_ids }).distinct
      else
        @jams = @jams.joins(:tags).group('jams.id').having('array_agg(tags.id) @> ARRAY[?]::bigint[]', tag_ids)
      end
    end

    respond_to do |format|
      format.html
      format.turbo_stream { @search_results = should_search? ? @jams : nil }
    end
  end

  def show
    @jam = Jam.find(params[:id])
    @jsb = @jam ? @jam.jam_submissions.find_by(user_id: current_user.id) : nil
    @game = @jsb && @jsb.game_id ? Game.find_by_id(@jsb.game_id) : nil
    if current_user
      @notifications = current_user.notifications
    end
  end

  def create
    @jam = Jam.new(jam_params.merge(author: current_user))

    @tags = Tag.all
    if @jam.save
      flash[:success] ||= []
      flash[:success] << 'Джем успешно создан!'
      redirect_to dashboard_path
    else
      flash[:failure] ||= []
      flash[:failure].concat(@jam.errors.full_messages)
      render :new, status: :see_other
    end
  rescue ActiveRecord::RecordNotUnique => e
    flash[:failure] ||= []
    flash[:failure] << "Джем с таким названием уже существует."
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
    if @jam.update(jam_params)
      redirect_to jam_profile_path, notice: 'Джем успешно обновлен.'
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
      flash[:success] << 'Джем успешно удален.'
    else
      flash[:failure] ||= []
      flash[:failure] << "Something went wrong!"
    end
    redirect_to :dashboard
  end

  private

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
end