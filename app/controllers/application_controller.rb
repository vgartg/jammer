class ApplicationController < ActionController::Base
  prepend_around_action :switch_locale
  around_action :set_time_zone

  helper_method :current_user
  before_action :check_user_freeze, unless: :logout_action?
  helper_method :notifications
  before_action :update_last_active_at
  include Pagy::Backend
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  protected

  def authenticate_user
    redirect_to login_path unless current_user
  end

  def require_no_authentication
    redirect_to news_path if current_user
  end

  def current_user
    return @current_user if @current_user && @current_user.email_confirmed

    browser = UserAgent.parse(request.user_agent).browser
    user_id = session[:current_user]

    if user_id.present? && Session.where(user_id: user_id, ip_address: request.remote_ip, browser: browser).exists?
      @current_user = User.find_by_id(user_id)
    elsif cookies.encrypted[:current_user].present?
      user = User.find_by_id(cookies.encrypted[:current_user])
      if user&.remember_token_authenticated?(cookies.encrypted[:remember_token])
        locale = session[:locale]
        reset_session
        session[:locale] = locale if locale.present?
        sign_in(user)
        Session.where(user_id: user.id, ip_address: request.remote_ip, browser: browser).destroy_all
        Session.create_session(user.id, session[:session_id], request.remote_ip, browser)
        @current_user = user
        return @current_user if @current_user.email_confirmed
      end
    end

    return @current_user if @current_user&.email_confirmed && @current_user.sessions.exists?

    @current_user = nil
  end

  def notifications
    return unless current_user
    return @_dropdown_notifications if @_dropdown_notifications

    @_dropdown_notifications = fetch_notifications(current_user)
  end

  def sign_in(user)
    session[:current_user] = user.id
  end

  private

  def admin?
    @user = current_user
    return if @user && @user.role == 'admin'

    flash[:failure] = t('controllers.application.insufficient_rights')
    redirect_to news_path
  end

  def moderator?
    @user = current_user
    return if @user && !@user.basic?

    flash[:failure] = t('controllers.application.insufficient_rights')
    redirect_to news_path
  end

  def create_administration_record(admin, item, changes, action)
    last_changes = changes.transform_values { |value| Array(value).last }
    first_changes = changes.transform_values { |value| Array(value).first }
    present_changes = last_changes.present? && first_changes.present?
    changed_fields = if present_changes && action != 'delete'
                       {
                         new_attributes: last_changes,
                         old_attributes: first_changes
                       }
                     elsif changes.present?
                       {
                         new_attributes: {},
                         old_attributes: changes
                       }
                     else
                       {}
                     end
    administration_record = AdministrationTracking.new(
      admin_id: admin.id,
      structure_type: item.class.name,
      structure_id: item.id,
      changed_fields: changed_fields,
      action: action
    )

    if administration_record.save
      Rails.logger.info("Administration record saved: #{administration_record.inspect}")
    else
      Rails.logger.error("Failed to save administration record: #{administration_record.errors.full_messages.join(', ')}")
    end
  end

  def update_last_active_at
    return unless current_user

    # Set before throttle so DailyActivityJob midnight reset doesn't miss the first request of a new day
    current_user.update_column(:is_online_today, true) unless current_user.is_online_today
    return if current_user.last_active_at && current_user.last_active_at > 5.minutes.ago

    current_user.update_column(:last_active_at, Time.current)
  end

  def fetch_notifications(user)
    notifs = user.notifications.includes(:actor, :notifiable).order(created_at: :desc).to_a
    jcs = notifs.filter_map(&:notifiable).grep(JamContributor)
    ActiveRecord::Associations::Preloader.new(records: jcs, associations: :jam).call if jcs.any?
    notifs
  end

  def render_404(exception = nil)
    logger.info "Rendering 404 with exception: #{exception.message}" if exception
    render template: 'errors/not_found', layout: 'error', status: 404
  end


  def switch_locale(&action)
    locale = locale_from_url || locale_from_headers || I18n.default_locale
    session[:locale] = locale.to_s
    response.set_header "Content-Language", locale
    I18n.with_locale locale, &action
  end

  def locale_from_url
    locale = params[:locale] || session[:locale]
    locale if I18n.available_locales.map(&:to_s).include?(locale.to_s)
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

  def check_user_freeze
    return unless current_user&.is_frozen?

    if current_user.unfreeze_at && current_user.unfreeze_at < Time.current
      current_user.update(frozen_at: nil, unfreeze_at: nil, frozen_reason: nil, is_frozen: false)
    else
      redirect_to frozen_path unless frozen_or_logout_path?
    end
  end

  def logout_action?
    request.path == logout_path
  end

  def frozen_or_logout_path?
    logout_action? || request.path == frozen_path
  end

  def set_time_zone(&block)
    raw = current_user&.timezone.presence || 'Europe/Moscow'
    tz_name = raw.sub(/\s*\(UTC[+-]\d{2}:\d{2}\)\z/, '')
    tz = ActiveSupport::TimeZone[tz_name] || ActiveSupport::TimeZone['Europe/Moscow']
    Time.use_zone(tz, &block)
  end
end
