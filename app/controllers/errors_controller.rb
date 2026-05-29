class ErrorsController < ActionController::Base
  layout 'error'
  before_action :set_locale

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end

  private

  def set_locale
    locale = locale_from_params || locale_from_original_path
    I18n.locale = I18n.available_locales.include?(locale&.to_sym) ? locale.to_sym : I18n.default_locale
  end

  def locale_from_params
    params[:locale].presence
  end

  def locale_from_original_path
    original_path = request.env['ORIGINAL_FULLPATH'].to_s
    original_path.match(%r{\A/(en|ru)(/|\z)})&.captures&.first
  end
end
