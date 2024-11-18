module Admin
  class JamsController < ApplicationController
    before_action :admin?
    before_action :set_jam!, only: %i[edit update destroy]

    def index
      jams = search_jams(Jam.all)
      jams = sort_jams(jams)
      @pagy, @jams = pagy(jams, limit: 10)
      if current_user
        @notifications = current_user.notifications
      end
    end

    def edit
      @jam = Jam.find(params[:id])
      if current_user
        @notifications = current_user.notifications
      end
    end

    def update
      old_status = @jam.status
      if @jam.update(jam_params)
        flash[:success] = 'Джем успешно обновлен'
        if old_status != @game.status
          @author = @jam.author
          @author.create_notification(@author, current_user, 'jam change status after moderation', @jam)
        end
      else
        flash[:failure] = @jam.errors.full_messages
      end
      redirect_to request.fullpath
    end

    def destroy
      @jam.destroy
      flash[:success] = 'Джем успешно удален'
      redirect_to admin_jams_path
    end

    private

    def set_jam!
      @jam = Jam.find params[:id]
    end

    def sort_jams(jams)
      sortable_columns = %w[id author_id name status created_at]
      sort_by = sortable_columns.include?(params[:sort_by]) ? params[:sort_by] : 'id'
      direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      jams.order("#{sort_by} #{direction}")
    end

    def search_jams(jams)
      if params[:query].present?
        query = params[:query].strip.downcase

        if query.to_i.to_s == query
          jams = jams.where("jams.id = :query OR jams.status = :query", query: query.to_i)
        else
          jams = jams.joins(:author).where("jams.name ILIKE :query OR jams.created_at::TEXT ILIKE :query OR users.name ILIKE :query", query: "%#{query}%")
        end
      end

      jams
    end

    def jam_params
      params.require(:jam)
            .permit(:name, :description, :start_date, :deadline, :end_date, :status, :cover, :logo, tag_ids: []).merge(admin_edit: true)
    end
  end
end