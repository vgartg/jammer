class OauthController < ApplicationController
  def callback
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

  def failure
    flash[:failure] = t('oauth.failure', message: params[:message].to_s.humanize)
    redirect_to login_path
  end

  private

  def attach_oauth_avatar(user, image_url)
    return if image_url.blank? || user.avatar.attached?

    require 'open-uri'
    download = URI.open(image_url)  # rubocop:disable Security/Open
    user.avatar.attach(
      io: download,
      filename: "avatar_#{user.id}.jpg",
      content_type: download.content_type
    )
  rescue => e
    Rails.logger.warn "OAuth avatar download failed for user #{user.id}: #{e.message}"
  end
end
