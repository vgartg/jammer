class ApplicationController < ActionController::Base
  helper_method :current_user
  helper_method :require_subdomain
  before_action :update_last_active_at
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  around_action :switch_locale

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

  def switch_locale(&action)
    locale = locale_from_url || locale_from_headers || I18n.default_locale
    response.set_header "Content-Language", locale
    I18n.with_locale locale, &action
  end

  def locale_from_url
    locale = params[:locale] || session[:locale]
    locale if I18n.available_locales.map(&:to_s).include?(locale)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  # Adapted from https://github.com/rack/rack-contrib/blob/main/lib/rack/contrib/locale.rb
  def locale_from_headers
    header = request.env['HTTP_ACCEPT_LANGUAGE']

    return if header.nil?

    locales = header.gsub(/\s+/, '').split(",").map do |language_tag|
      locale, quality = language_tag.split(/;q=/i)
      quality = quality ? quality.to_f : 1.0
      [locale, quality]
    end.reject do |(locale, quality)|
      locale == '*' || quality == 0
    end.sort_by do |(_, quality)|
      quality
    end.map(&:first)

    return if locales.empty?

    if I18n.enforce_available_locales
      locale = locales.reverse.find { |locale| I18n.available_locales.any? { |al| match(al, locale) } }
      if locale
        I18n.available_locales.find { |al| match(al, locale) }
      end
    else
      locales.last
    end
  end

  def match(s1, s2)
    s1.to_s.casecmp(s2.to_s) == 0
  end
end
