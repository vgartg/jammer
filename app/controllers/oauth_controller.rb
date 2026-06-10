class OauthController < ApplicationController
  def callback
    flash[:failure] = t('oauth.disabled')
    redirect_to login_path and return unless request.env['omniauth.auth']

    auth = request.env['omniauth.auth']

    unless auth&.info&.email.present?
      flash[:failure] = t('oauth.no_email')
      redirect_to login_path and return
    end

    user = User.from_omniauth(auth)

    browser = UserAgent.parse(request.user_agent).browser
    locale = session[:locale]
    reset_session
    session[:locale] = locale if locale.present?
    session[:current_user] = user.id

    Session.where(user_id: user.id, ip_address: request.remote_ip, browser: browser).destroy_all
    Session.create_session(user.id, session[:session_id], request.remote_ip, browser)

    attach_oauth_avatar(user, auth.info.image) if user.previously_new_record?

    if user.previously_new_record?
      if user.oauth_name_changed?
        flash[:success] = t('oauth.username_taken',
                            requested: user.oauth_requested_name,
                            assigned: user.name)
      end
      redirect_to settings_path
    else
      redirect_to news_path
    end
  end

  MAX_AVATAR_SIZE = 5 * 1024 * 1024

  def failure
    error_type = request.env['omniauth.error.type']&.to_s || ''
    message = error_type.match?(/\A\w+\z/) ? error_type.humanize : 'Unknown error'
    flash[:failure] = t('oauth.failure', message: message)
    redirect_to login_path
  end

  private

  def attach_oauth_avatar(user, image_url)
    return if image_url.blank? || user.avatar.attached?

    uri = URI.parse(image_url)
    return unless uri.is_a?(URI::HTTP)

    require 'open-uri'
    uri.open('read_timeout' => 10) do |download|
      data = download.read(MAX_AVATAR_SIZE + 1)
      if data.bytesize > MAX_AVATAR_SIZE
        Rails.logger.warn "OAuth avatar too large for user #{user.id}, skipping"
        next
      end
      user.avatar.attach(
        io: StringIO.new(data),
        filename: "avatar_#{user.id}.jpg",
        content_type: download.content_type
      )
    end
  rescue URI::InvalidURIError
    Rails.logger.warn "OAuth avatar has invalid URL for user #{user.id}: #{image_url}"
  rescue => e
    Rails.logger.warn "OAuth avatar download failed for user #{user.id}: #{e.message}"
  end
end
