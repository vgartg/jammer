class FrozenController < ApplicationController
  skip_before_action :check_user_freeze
  before_action :authenticate_user
  layout 'error'

  def show
    redirect_to dashboard_path unless current_user&.is_frozen?
  end
end
