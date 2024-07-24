class ApplicationController < ActionController::Base
  helper_method :current_user
  before_action :update_last_active_at
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  rescue_from ActionController::RoutingError, :with => :render_404

  protected
  def authenticate_user
    redirect_to login_path unless current_user
  end
  def current_user
    @current_user ||= User.find_by_id(session[:current_user])
  end

  private
  def update_last_active_at
    if current_user
      current_user.update(last_active_at: Time.current)
    end
  end
  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}" if exception
    end
    render template: 'errors/not_found', status: 404
  end

end