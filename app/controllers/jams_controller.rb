class JamsController < ApplicationController
  before_action :authenticate_user, only: [:new, :create, :edit, :update]

  def new
    @notifications = current_user.notifications
  end

  def showcase
    @search_results = nil
    @tags = Tag.all
    if current_user
      @notifications = current_user.notifications
    end

    if should_search?
      lower_case_search = "%#{params[:search].downcase}%"
      jams = Jam.where("LOWER(jams.name) LIKE ? OR LOWER(jams.description) LIKE ?",
                        lower_case_search, lower_case_search)
      @pagy, @jams = pagy(jams, limit: 12)
    else
      @pagy, @jams = pagy(Jam.all, limit: 12)
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
    if current_user
      @notifications = current_user.notifications
    end
  end

  def create
    @jam = Jam.new(jam_params.merge(author: current_user))
    @tags = Tag.all
    if @jam.save
      flash[:success] = 'Джем успешно создан!'
      redirect_to dashboard_path
    else
      flash[:failure] = @jam.errors.full_messages
      render :new, status: :see_other
    end
  rescue ActiveRecord::RecordNotUnique => e
    flash[:failure] = "Джем с таким названием уже существует."
    render :new, status: :see_other
  end

  def edit
    @jam = current_user.jams.find_by_id(params[:id])
    @tags = Tag.all
  end

  def update
    @jam = current_user.jams.find_by_id(params[:id])
    if @jam.update(jam_params)
      redirect_to jam_profile_path, notice: 'Джем успешно обновлен.'
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
      flash[:failure] = "Something went wrong!"
    end
    redirect_to :dashboard
  end

  private

  def jam_params
    params.require(:jam)
          .permit(:name, :description, :start_date, :deadline, :end_date, :cover, :logo, tag_ids: [])
  end

  def should_search?
    params[:search].present? && !params[:search].empty?
  end
end