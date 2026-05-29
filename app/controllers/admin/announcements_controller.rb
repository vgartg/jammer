module Admin
  class AnnouncementsController < ApplicationController
    before_action :admin?
    before_action :set_announcement, only: %i[edit update destroy]

    def index
      @announcements = Announcement.includes(:author).order(created_at: :desc)
      @pagy, @announcements = pagy(@announcements, limit: 20)
    end

    def new
      @announcement = Announcement.new
    end

    def create
      @announcement = Announcement.new(announcement_params.merge(author: current_user))
      if params[:publish]
        @announcement.published = true
        @announcement.published_at = Time.current
      end
      if @announcement.save
        create_administration_record(current_user, @announcement, {}, 'create')
        flash[:success] = t('admin.announcements.created')
        redirect_to admin_announcements_path
      else
        flash[:failure] = @announcement.errors.full_messages
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      was_published = @announcement.published?
      if params[:publish] && !was_published
        announcement_params_merged = announcement_params.merge(published: true, published_at: Time.current)
      else
        announcement_params_merged = announcement_params
      end
      if @announcement.update(announcement_params_merged)
        create_administration_record(current_user, @announcement, @announcement.previous_changes.except('updated_at'), 'edit')
        flash[:success] = t('admin.announcements.updated')
        redirect_to admin_announcements_path
      else
        flash[:failure] = @announcement.errors.full_messages
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      create_administration_record(current_user, @announcement, {}, 'delete') if @announcement.destroy
      flash[:success] = t('admin.announcements.deleted')
      redirect_to admin_announcements_path
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(:announcement_type, :version, :title_en, :title_ru, :body_en, :body_ru, :published)
    end
  end
end
