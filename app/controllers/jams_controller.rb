# frozen_string_literal: true

class JamsController < ApplicationController
  before_action :authenticate_user, only: %i[new create edit update submit_game participate delete_project]
  before_action :set_jam, only: %i[show edit update destroy
  show_projects show_participants remove_participant remove_project
  rating_settings update_rating_settings
  jury_settings jury_search jury_invite update_contributor remove_contributor accept_contributor_invite bulk_update_contributors
  update_nomination_winner
]
  before_action :jam_manage_check, only: %i[
  edit update destroy
  remove_participant remove_project
  jury_invite update_contributor remove_contributor bulk_update_contributors
]

  before_action :jam_configure_check, only: %i[
  rating_settings update_rating_settings
  jury_settings
]

  before_action :submission_open_check, only: %i[participate delete_project create_submission submit_game]

  def new
    @notifications = current_user.notifications
    @jam = Jam.new
  end

  def participate
    unless JamSubmission.where(jam_id: params[:id]).find_by(user_id: current_user.id).present?
      jsb = JamSubmission.new(game_id: nil, jam_id: params[:id], user: current_user)
      if jsb.save
        flash[:notice] = t('controllers.jams.participate_success')
      else
        flash[:alert] = t('controllers.jams.participate_failure')
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
    @tags = Tag.all
    @games = @jam.submitted_games.includes(:ratings)

    winner_map = {}
    @jam.jam_nominations.where.not(winner_game_id: nil).find_each do |n|
      winner_map[n.winner_game_id] ||= []
      winner_map[n.winner_game_id] << n.title
    end
    @winner_titles_by_game_id = winner_map

    if current_user && @jam.judge?(current_user)
      reviewed_ids = Review.where(jam_id: @jam.id, user_id: current_user.id).distinct.pluck(:game_id)
      picked_ids   = JamCriterionPick.where(jam_id: @jam.id, voter_id: current_user.id).distinct.pluck(:game_id)
      @judged_game_ids = (reviewed_ids + picked_ids).to_set
    else
      @judged_game_ids = Set.new
    end

    if should_search?
      lower_case_search = "%#{params[:search].downcase}%"
      @games = Game.where("LOWER(games.name) LIKE ? OR LOWER(games.description) LIKE ?",
                          lower_case_search, lower_case_search)
    end

    respond_to do |format|
      format.html
      format.turbo_stream { @search_results = should_search? ? @games : nil }
    end
  end

  def show_participants
    @users = @jam.participants
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
                @jams.joins(:tags)
                     .where(tags: { id: tag_ids })
                     .group('jams.id')
                     .having('COUNT(DISTINCT tags.id) = ?', tag_ids.size)
              end
    end

    respond_to do |format|
      format.html
      format.turbo_stream { @search_results = should_search? ? @jams : nil }
    end
  end

  def show
    @submission_open = @jam.submission_open?
    @jsb = current_user ? @jam.jam_submissions.find_by(user_id: current_user.id) : nil
    @game = @jsb&.game_id ? Game.find_by_id(@jsb.game_id) : nil
    @notifications = current_user.notifications if current_user
    if @jam.status != 1 && current_user != @jam.author
      flash[:failure] = @jam.status == 2 ? t('controllers.jams.rejected') : t('controllers.jams.moderation_pending')
      redirect_to news_path and return
    end

    @leaderboard_games = @jam.leaderboard_games
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
    elsif @jam.save
      User.notify_staff(current_user, 'awaiting_jam_moderation', @jam)
      flash[:success] ||= []
      flash[:success] << t('jams.create.success')
      redirect_to news_path
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
    @tags = Tag.all
  end

  def submit_game
    @game = Game.new
  end

  def create_submission
    @game = Game.new(game_params.merge(author: current_user))
    if @game.save
      submission = JamSubmission.where(jam_id: params[:id]).find_by(user_id: current_user.id)
      submission.update(game_id: @game.id)
      redirect_to jam_profile_path(params[:id])
    else
      redirect_to news_path
    end
  end

  def update
    failures = invalid_date
    @tags = Tag.all
    if failures.any?
      flash[:failure] ||= []
      failures.each do |problem|
        flash[:failure] << problem
      end
      render :edit, status: :see_other
    elsif @jam.update(jam_params)
      User.notify_staff(current_user, 'awaiting_jam_moderation', @jam)
      @jam.update(status: 0)
      flash[:success] = t('controllers.jams.update_resubmitted')
      redirect_to jam_profile_path
    else
      flash[:failure] ||= []
      flash[:failure].concat(@jam.errors.full_messages)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @jam.destroy
      flash[:success] ||= []
      flash[:success] << t('jams.destroy.success')
    else
      flash[:failure] ||= []
      flash[:failure] << t('jams.destroy.failure')
    end
    redirect_to :dashboard
  end

  def remove_participant
    submission = @jam.jam_submissions.find_by(user_id: params[:user_id])
    if submission&.destroy
      flash[:notice] = t('controllers.jams.participant_removed')
    else
      flash[:alert] = t('controllers.jams.participant_remove_failed')
    end
    redirect_to jam_show_participants_path(@jam)
  end

  def remove_project
    submission = @jam.jam_submissions.find_by(game_id: params[:game_id])
    if submission&.update(game_id: nil)
      flash[:notice] = t('controllers.jams.project_unlinked')
    else
      flash[:alert] = t('controllers.jams.project_unlink_failed')
    end
    redirect_to jam_show_projects_path(@jam)
  end

  # ===== Rating settings =====
  def rating_settings
    @setting = @jam.rating_setting
    @criteria = @jam.jam_criteria.active.order(:position, :id)
    @nominations = @jam.jam_nominations.order(:position, :id)
    @games = @jam.submitted_games
  end

  def update_rating_settings
    @setting = @jam.rating_setting

    # 1) сохраняем тумблеры
    if @setting.locked
      flash[:failure] = t('controllers.jams.settings_locked')
      return redirect_to rating_settings_jam_path(@jam)
    end

    @setting.assign_attributes(rating_setting_params)

    # 2) критерии (SYNC, без destroy_all)
    criteria_params = Array(params[:criteria])

    kept_ids = []
    position = 0

    criteria_params.each do |c|
      cid = c[:id].presence
      title = c[:title].to_s.strip
      kind = c[:kind].to_s
      kind = "voted_on" unless %w[voted_on manually_ranked].include?(kind)

      # Пустая строка в форме = “удалить/пропустить”
      if title.blank?
        next
      end

      if cid.present?
        crit = @jam.jam_criteria.find(cid)
        old_title = crit.title
        crit.update!(title: title, kind: kind, position: position, archived: false)

        if old_title != title
          Review.where(jam_id: @jam.id, criterion: old_title).update_all(criterion: title)
        end
        kept_ids << crit.id
      else
        crit = @jam.jam_criteria.create!(title: title, kind: kind, position: position, archived: false)
        kept_ids << crit.id
      end

      position += 1
    end

    # Всё, что не осталось в форме — либо архивируем, либо удаляем если нет данных
    to_remove = @jam.jam_criteria.where(archived: false).where.not(id: kept_ids)

    to_remove.find_each do |crit|
      has_picks = JamCriterionPick.where(jam_criterion_id: crit.id).exists?
      has_reviews = Review.where(jam_id: @jam.id, criterion: crit.title).exists?

      if has_picks || has_reviews
        crit.update!(archived: true)
      else
        crit.destroy!
      end
    end

    # 3) номинации (SYNC, без destroy_all)
    noms_params = Array(params[:nominations])

    kept_nom_ids = []
    pos = 0

    noms_params.each do |n|
      nid = n[:id].presence
      title = n[:title].to_s.strip
      next if title.blank?

      if nid.present?
        nom = @jam.jam_nominations.find(nid)
        nom.update!(title: title, position: pos)
        kept_nom_ids << nom.id
      else
        nom = @jam.jam_nominations.create!(title: title, position: pos)
        kept_nom_ids << nom.id
      end

      pos += 1
    end

    # что не осталось в форме — удаляем (у номинаций нет FK на picks, можно удалять спокойно)
    @jam.jam_nominations.where.not(id: kept_nom_ids).destroy_all

    # 4) победители номинаций (из общей формы)
    winners_params = Array(params[:nominations_winners])

    winners_params.each do |row|
      nid = row[:id].presence
      next if nid.blank?

      nomination = @jam.jam_nominations.find(nid)

      winner_id = row[:winner_game_id].presence

      # (опционально) проверка: игра должна быть из этого джема
      if winner_id.present?
        allowed_game_ids = @jam.submitted_game_ids
        next unless allowed_game_ids.include?(winner_id.to_i)
      end

      nomination.update!(winner_game_id: winner_id)
    end

    if @setting.save
      flash[:success] = t('controllers.jams.ratings_saved')
    else
      flash[:failure] ||= []
      flash[:failure] += @setting.errors.full_messages
    end

    redirect_to rating_settings_jam_path(@jam)
  end

  # ===== Jury settings =====
  def jury_settings
    @contributors = @jam.jam_contributors.includes(:user).order(:created_at)
    @pending = @contributors.select { |c| c.status == "pending" }
    @accepted = @contributors.select { |c| c.status == "accepted" }

    @users = User.order(:name) # чтобы в форме выбирать (быстро и просто)
  end

  def jury_invite
    user = User.find_by(id: params[:user_id])

    unless user
      flash[:failure] = [t('controllers.jams.user_not_found')]
      return redirect_to jury_settings_jam_path(@jam)
    end

    contributor = @jam.jam_contributors.find_or_initialize_by(user_id: user.id)
    contributor.status ||= "pending"
    contributor.judge = true if contributor.new_record?

    if contributor.save
      User.create_notification(user, current_user, "sent_jam_jury_invite", contributor)
      flash[:success] ||= []
      flash[:success] << t('controllers.jams.invite_sent')
    else
      flash[:failure] ||= []
      flash[:failure] += contributor.errors.full_messages
    end

    @contributors = @jam.jam_contributors.includes(:user).order(:created_at)

    respond_to do |format|
      format.html { redirect_to jury_settings_jam_path(@jam) }

      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "jam_contributors_table",
            partial: "jams/jury_contributors_table",
            locals: { jam: @jam, contributors: @contributors }
          ),
          turbo_stream.replace(
            "flash_notices",
            partial: "helpers/flash_notices"
          ),
          turbo_stream.update("jury_search_results", "")
        ]
      end
    end
  end

  def accept_contributor_invite
    contributor = @jam.jam_contributors.find_by(id: params[:contributor_id], user_id: current_user.id)
    unless contributor
      flash[:failure] = t('controllers.jams.invite_not_found')
      return redirect_to jam_profile_path(@jam)
    end

    if contributor.update(status: "accepted")
      # нотифицируем автора джема
      User.create_notification(@jam.author, current_user, "accepted_jam_jury_invite", contributor)
      flash[:success] = t('controllers.jams.invite_accepted')
    else
      flash[:failure] = t('controllers.jams.invite_accept_failed')
    end

    redirect_to jam_profile_path(@jam)
  end

  def update_contributor
    contributor = @jam.jam_contributors.find(params[:contributor_id])

    if contributor.update(contributor_params)
      flash.now[:success] = t('controllers.jams.roles_updated')
    else
      flash.now[:failure] ||= []
      flash.now[:failure] += contributor.errors.full_messages
    end

    @contributors = @jam.jam_contributors.includes(:user).order(:created_at)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to jury_settings_jam_path(@jam), status: :see_other }
    end
  end

  def bulk_update_contributors
    jam_manage_check

    payload = params.fetch(:contributors, {}) # { "3" => {"host"=>"0","admin"=>"1","judge"=>"1"}, ... }

    ActiveRecord::Base.transaction do
      payload.each do |id, attrs|
        c = @jam.jam_contributors.find(id)
        c.update!(
          host: ActiveModel::Type::Boolean.new.cast(attrs[:host]),
          admin: ActiveModel::Type::Boolean.new.cast(attrs[:admin]),
          judge: ActiveModel::Type::Boolean.new.cast(attrs[:judge])
        )
      end
    end

    flash.now[:success] = t('controllers.jams.roles_updated')
    @contributors = @jam.jam_contributors.includes(:user).order(:created_at)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to jury_settings_jam_path(@jam), status: :see_other }
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:failure] = e.record.errors.full_messages
    @contributors = @jam.jam_contributors.includes(:user).order(:created_at)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to jury_settings_jam_path(@jam), status: :see_other }
    end
  end

  def remove_contributor
    contributor = @jam.jam_contributors.find(params[:contributor_id])
    contributor.destroy
    flash[:success] = t('controllers.jams.contributor_removed')
    redirect_to jury_settings_jam_path(@jam)
  end

  def jury_search
    jam_manage_check

    q = params[:q].to_s.strip.downcase

    return render html: "" if q.length < 2

    # ID уже добавленных
    excluded_ids = @jam.jam_contributors.pluck(:user_id)

    @users =
      User.where("LOWER(name) LIKE :q OR LOWER(email) LIKE :q", q: "%#{q}%")
          .where.not(id: excluded_ids)
          .limit(10)

    render partial: "jams/jury_search_results",
           locals: { users: @users, jam: @jam }
  end

  def update_nomination_winner
    unless @jam.can_configure?(current_user)
      flash[:failure] = [t('controllers.application.insufficient_rights')]
      return redirect_to rating_settings_jam_path(@jam), status: :see_other
    end

    nomination = @jam.jam_nominations.find(params[:nomination_id])

    winner_id = params[:winner_game_id].presence

    # Проверяем что игра из этого джема (или пусто)
    if winner_id.present?
      allowed_game_ids = @jam.submitted_game_ids
      unless allowed_game_ids.include?(winner_id.to_i)
        flash.now[:failure] = [t('controllers.jams.game_not_in_jam')]
        return respond_winner_update(nomination)
      end
    end

    nomination.update!(winner_game_id: winner_id)
    flash.now[:success] = t('controllers.jams.winner_saved')

    respond_winner_update(nomination)
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:failure] = e.record.errors.full_messages
    respond_winner_update(nomination)
  end

  private

  def respond_winner_update(_nomination)
    @nominations = @jam.jam_nominations.where(archived: false).order(:position, :id) rescue @jam.jam_nominations.order(:position, :id)
    @games = @jam.submitted_games

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to rating_settings_jam_path(@jam), status: :see_other }
    end
  end

  def set_jam
    @jam = Jam.find(params[:id])
  end

  def author_or_admin
    unless current_user && (current_user == @jam.author || current_user.role.in?([1, 2]))
      flash[:failure] = t('controllers.application.insufficient_rights')
      redirect_to news_path
    end
  end

  def root_check
    return if current_user.jams.find_by_id(params[:id])

    flash[:failure] = t('controllers.application.insufficient_rights')
    redirect_to news_path
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
          .permit(:name, :description, :cover, :cover_cache, :game_file, tag_ids: [])
  end

  def invalid_date
    failures = []

    start_date = (Date.parse(params.dig(:jam, :start_date).to_s) rescue (failures << t('controllers.jams.date_invalid_start'); nil))
    deadline   = (Date.parse(params.dig(:jam, :deadline).to_s)   rescue (failures << t('controllers.jams.date_invalid_deadline'); nil))
    end_date   = (Date.parse(params.dig(:jam, :end_date).to_s)   rescue (failures << t('controllers.jams.date_invalid_end'); nil))

    return failures if failures.any?

    failures << t('controllers.jams.date_deadline_before_start') if deadline < start_date
    failures << t('controllers.jams.date_end_before_deadline')   if end_date < deadline
    failures << t('controllers.jams.date_invalid_start')         if start_date.year < 2000
    failures << t('controllers.jams.date_invalid_deadline')      if deadline.year < 2000
    failures << t('controllers.jams.date_invalid_end')           if end_date.year < 2000

    failures
  end

  def jam_manage_check
    unless @jam.can_manage?(current_user)
      flash[:failure] = t('controllers.application.insufficient_rights')
      redirect_to news_path
    end
  end

  def jam_configure_check
    unless @jam.can_configure?(current_user)
      flash[:failure] = t('controllers.application.insufficient_rights')
      redirect_to news_path
    end
  end

  def rating_setting_params
    params.require(:jam_rating_setting).permit(:jury_enabled, :audience_enabled)
  end

  def contributor_params
    params.require(:jam_contributor).permit(:host, :admin, :judge)
  end

  def submission_open_check
    jam = @jam || Jam.find(params[:id] || params[:jam_id])

    return if jam.submission_open?

    flash[:failure] = t('controllers.jams.submission_closed')
    redirect_to jam_profile_path(jam)
  end
end
