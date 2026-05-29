class AssetsController < ApplicationController
  before_action :authenticate_user, only: %i[new create edit update destroy download]
  before_action :set_asset, only: %i[show edit update destroy download]
  before_action :authorize_asset!, only: %i[edit update destroy]

  def index
    @assets = Asset.all.order(created_at: :desc)
    @assets = @assets.by_category(params[:category]) if params[:category].present?
    @assets = @assets.search(params[:search]) if params[:search].present?
    @pagy, @assets = pagy(@assets.includes(:author), limit: 12)
  end

  def show
  end

  def new
    @asset = Asset.new
  end

  def create
    @asset = Asset.new(asset_params.merge(author: current_user))
    if @asset.save
      flash[:success] = t('assets.create.success')
      redirect_to asset_profile_path(@asset)
    else
      flash[:failure] = @asset.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    update_params = asset_params
    unless params.dig(:asset, :files).present?
      update_params = update_params.except('files')
    end
    if @asset.update(update_params)
      flash[:success] = t('assets.update.success')
      redirect_to asset_profile_path(@asset)
    else
      flash[:failure] = @asset.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    flash[:success] = t('assets.destroy.success')
    redirect_to assets_path
  end

  def download
    unless @asset.files.attached?
      flash[:failure] = t('assets.download.no_file')
      return redirect_to asset_profile_path(@asset)
    end

    file = if params[:blob_signed_id].present?
             @asset.files.find { |f| f.blob.signed_id == params[:blob_signed_id] }
           end
    file ||= @asset.files.first

    @asset.increment!(:downloads_count)
    redirect_to url_for(file), allow_other_host: true
  end

  private

  def set_asset
    @asset = Asset.includes(
      { author: { avatar_attachment: :blob } },
      files_attachments: :blob,
      preview_attachment: :blob
    ).find(params[:id])
  end

  def authorize_asset!
    return if current_user == @asset.author || current_user.admin?

    flash[:failure] = t('controllers.application.insufficient_rights')
    redirect_to dashboard_path
  end

  def asset_params
    params.require(:asset).permit(:title, :description, :category, :preview, :guide, files: [])
  end
end
