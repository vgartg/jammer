# frozen_string_literal: true

class JamsController < ApplicationController
  before_action :authenticate_user, only: %i[new create edit update submit_game participate delete_project]
  before_action :set_jam, only: %i[edit update destroy
  show_projects show_participants remove_participant remove_project
  rating_settings update_rating_settings
  jury_settings jury_invite update_contributor remove_contributor accept_contributor_invite bulk_update_contributors
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
    submissions = @jam.jam_submissions
                      .where.not(game_id: nil)
                      .includes(game: :ratings)
    @games = submissions.map(&:game)

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
    @jam = Jam.find(params[:id])
    @users = @jam.jam_submissions.includes(:user).map(&:user)
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
      redirect_to dashboard_path
    end
  end

  def update
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
      flash[:notice] = "Участник удалён из джема."
    else
      flash[:alert] = "Не удалось удалить участника."
    end
    redirect_to jam_show_participants_path(@jam)
  end

  def remove_project
    submission = @jam.jam_submissions.find_by(game_id: params[:game_id])
    if submission&.update(game_id: nil)
      flash[:notice] = "Проект отвязан от джема."
    else
      flash[:alert] = "Не удалось удалить проект."
    end
    redirect_to jam_show_projects_path(@jam)
  end

  # ===== Rating settings =====
  def rating_settings
    @setting = @jam.rating_setting
    @criteria = @jam.jam_criteria.active.order(:position, :id)
    @nominations = @jam.jam_nominations.order(:position, :id)
  end

  def update_rating_settings
    @setting = @jam.rating_setting

    # 1) сохраняем тумблеры
    if @setting.locked
      flash[:failure] = "Настройки заблокированы"
      return redirect_to rating_settings_jam_path(@jam)
    end

    @setting.assign_attributes(rating_setting_params)

    # 2) критерии (SYNC, без destroy_all)
    criteria_params = Array(params[:criteria])

    kept_ids = []
    position = 0

    criteria_params.each do |c|
      cid  = c[:id].presence
      title = c[:title].to_s.strip
      kind  = c[:kind].to_s
      kind  = "voted_on" unless %w[voted_on manually_ranked].include?(kind)

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

    # 3) номинации
    if params[:nominations]
      @jam.jam_nominations.destroy_all
      params[:nominations].each_with_index do |n, idx|
        title = n[:title].to_s.strip
        next if title.blank?
        method = n[:method].to_s
        method = "manual" unless %w[manual audience_based].include?(method)
        @jam.jam_nominations.create!(title: title, method: method, position: idx)
      end
    end

    if @setting.save
      flash[:success] = "Настройки оценок сохранены"
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
      flash[:failure] = ["Пользователь не найден"]
      return redirect_to jury_settings_jam_path(@jam)
    end

    contributor = @jam.jam_contributors.find_or_initialize_by(user_id: user.id)
    contributor.status ||= "pending"
    contributor.judge = true if contributor.new_record?

    if contributor.save
      current_user.create_notification(user, current_user, "sent_jam_jury_invite", contributor)
      flash[:success] ||= []
      flash[:success] << "Инвайт отправлен"
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
      flash[:failure] = "Инвайт не найден"
      return redirect_to jam_profile_path(@jam)
    end

    if contributor.update(status: "accepted")
      # нотифицируем автора джема
      current_user.create_notification(@jam.author, current_user, "accepted_jam_jury_invite", contributor)
      flash[:success] = "Вы приняли приглашение"
    else
      flash[:failure] = "Не удалось принять приглашение"
    end

    redirect_to jam_profile_path(@jam)
  end

  def update_contributor
    contributor = @jam.jam_contributors.find(params[:contributor_id])

    if contributor.update(contributor_params)
      flash.now[:success] = "Роли обновлены"
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

    flash.now[:success] = "Роли обновлены"
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
    flash[:success] = "Удалено"
    redirect_to jury_settings_jam_path(@jam)
  end

  def jury_search
    @jam = Jam.find(params[:id])
    jam_manage_check

    q = params[:q].to_s.strip.downcase

    return render html: "" if q.length < 2

    # ID уже добавленных
    excluded_ids = @jam.jam_contributors.pluck(:user_id)
    excluded_ids << @jam.author_id

    @users =
      User.where("LOWER(name) LIKE :q OR LOWER(email) LIKE :q", q: "%#{q}%")
          .where.not(id: excluded_ids)
          .limit(10)

    render partial: "jams/jury_search_results",
           locals: { users: @users, jam: @jam }
  end

  private

  def set_jam
    @jam = Jam.find(params[:id])
  end

  def author_or_admin
    unless current_user && (current_user == @jam.author || current_user.role.in?([1, 2]))
      flash[:failure] = "Недостаточно прав"
      redirect_to dashboard_path
    end
  end

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

  def jam_manage_check
    unless @jam.can_manage?(current_user)
      flash[:failure] = "Недостаточно прав"
      redirect_to dashboard_path
    end
  end

  def jam_configure_check
    unless @jam.can_configure?(current_user)
      flash[:failure] = "Недостаточно прав"
      redirect_to dashboard_path
    end
  end

  def rating_setting_params
    params.require(:jam_rating_setting).permit(:jury_enabled, :audience_enabled)
  end

  def contributor_params
    params.require(:jam_contributor).permit(:host, :admin, :judge, :status)
  end
end
