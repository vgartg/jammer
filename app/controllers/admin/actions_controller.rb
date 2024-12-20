class Admin::ActionsController < ApplicationController
  before_action :admin?

  def index
    @pagy, @actions = pagy(AdministrationTracking.all.order(created_at: :desc), limit: 15)
  end
end
