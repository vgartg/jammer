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
      announcement_params_merged = if params[:publish] && !was_published
        announcement_params.merge(published: true, published_at: Time.current)
      elsif params[:unpublish] && was_published
        announcement_params.merge(published: false, published_at: nil)
      else
        announcement_params
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
      if @announcement.destroy
        create_administration_record(current_user, @announcement, {}, 'delete')
        flash[:success] = t('admin.announcements.deleted')
      else
        flash[:failure] = @announcement.errors.full_messages
      end
      redirect_to admin_announcements_path
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(:announcement_type, :version, :title_en, :title_ru, :body_en, :body_ru)
    end
  end
end
