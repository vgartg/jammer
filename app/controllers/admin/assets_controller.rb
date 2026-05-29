module Admin
  class AssetsController < ApplicationController
    before_action :admin?

    def index
      @assets = Asset.includes(:author).order(created_at: :desc)
      if params[:search].present?
        q = "%#{params[:search].downcase}%"
        @assets = @assets.where('LOWER(assets.title) LIKE ?', q)
      end
      @pagy, @assets = pagy(@assets, limit: 20)
    end

    def destroy
      asset = Asset.find(params[:id])
      create_administration_record(current_user, asset, {}, 'delete') if asset.destroy
      flash[:success] = t('admin.assets.deleted')
      redirect_to admin_assets_path
    end
  end
end
