class JamsController < ApplicationController
  before_action :authenticate_user, only: %i[new create edit update]
  before_action :root_check, only: %i[edit update destroy]

  def new; end

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
    return unless @jam.status != 1 && current_user != @jam.author

    flash[:failure] = 'Джем находится на модерации'
    redirect_to dashboard_path
  end

  def create
    @jam = Jam.new(jam_params.merge(author: current_user))
    @tags = Tag.all
    if @jam.save
      admins = User.where(role: [1, 2])
      admins.each do |admin|
        current_user.create_notification(admin, current_user, 'awaiting jam moderation', @jam)
      end
      flash[:success] = 'Джем успешно создан!'
      redirect_to dashboard_path
    else
      flash[:failure] = @jam.errors.full_messages
      render :new, status: :see_other
    end
  rescue ActiveRecord::RecordNotUnique
    flash[:failure] = 'Джем с таким названием уже существует.'
    render :new, status: :see_other
  end

  def edit
    @jam = current_user.jams.find_by_id(params[:id])
    @tags = Tag.all
  end

  def update
    @jam = current_user.jams.find_by_id(params[:id])
    if @jam.update(jam_params)
      admins = User.where(role: [1, 2])
      admins.each do |admin|
        current_user.create_notification(admin, current_user, 'awaiting jam moderation', @jam)
      end
      @jam.update(status: 0)
      flash[:success] = 'Джем обновлен и отправлен на повторную модерацию!'
      redirect_to jam_profile_path
    else
      flash[:failure] = @jam.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @jam = current_user.jams.find_by_id(params[:id])
    if @jam.destroy
      flash[:success] = 'Джем успешно удален.'
    else
      flash[:failure] = 'Something went wrong!'
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
          .permit(:name, :description, :start_date, :deadline, :end_date, :cover, :logo, tag_ids: [])
  end

  def should_search?
    params[:search].present? && !params[:search].empty?
  end
end
