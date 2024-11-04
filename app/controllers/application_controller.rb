class ApplicationController < ActionController::Base
  helper_method :current_user
  helper_method :require_subdomain
  before_action :update_last_active_at
  include Pagy::Backend
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  protected

  def authenticate_user
    redirect_to login_path unless current_user
  end

  def require_no_authentication
    redirect_to dashboard_path if current_user
  end

  def current_user
    return @current_user if @current_user && @current_user.email_confirmed

    browser_string = request.user_agent
    browser = UserAgent.parse(browser_string).browser
    if session[:current_user] && Session.all.where(ip_address: request.remote_ip, browser: browser).exists?
      @current_user = User.find_by_id(session[:current_user])
    elsif cookies.encrypted[:current_user].present?
      user = User.find_by_id(cookies.encrypted[:current_user])
      if user&.remember_token_authenticated?(cookies.encrypted[:remember_token])
        sign_in(user)
        @current_user = user
      end
    end

    if @current_user && session[:session_id].present? && @current_user.sessions.where(user_id: @current_user.id).exists?
      return @current_user
    end

    @current_user = nil
  end

  def sign_in(user)
    session[:current_user] = user.id
  end

  private

  def admin?
    @user = current_user
    unless @user && @user.role == 'admin'
      flash[:failure] = 'Недостаточно прав'
      redirect_to dashboard_path
    end
  end

  def update_last_active_at
    if current_user
      current_user.update(last_active_at: Time.current)
    end
  end

  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end
    render template: 'errors/not_found', status: 404
  end

  def require_subdomain
    subdomain = Subdomain.extract_subdomain(request)
    if subdomain == "localhost" || subdomain == "127" # Пока такой костыль, на продакшене нужно поменять
      render 'home/index'
    else
      @subdomain_owner = User.find_by_link_username(subdomain)
      render_404 unless @subdomain_owner
    end
  end
end
