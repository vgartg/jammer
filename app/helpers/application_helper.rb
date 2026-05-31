module ApplicationHelper
  include Pagy::Frontend

  def toggle_direction(column)
    if params[:sort_by] == column
      params[:direction] == 'asc' ? 'desc' : 'asc'
    else
      'asc'
    end
  end

  def sort_arrow(column)
    if params[:sort_by] == column
      params[:direction] == 'asc' ? '▲' : '▼'
    else
      ''
    end
  end

  def profile_path_for(user)
    user.link_username.present? ? frontpage_path(username: user.link_username) : user_profile_path(user)
  end

  def notification_message(notification)
    return '' if notification.blank? || notification.action.blank?

    key = notification.action.to_s.strip.downcase.tr(' ', '_')

    I18n.t(
      "notifications.actions.#{key}",
      type: notification.notifiable_type,
      id: notification.notifiable_id,
      default: notification.action
    )
  end

  # Renders announcement body with auto-linked URLs and preserved newlines.
  # - Bare domains like github.com/foo are linked (display text kept as-is, no https:// prepended visually)
  # - Full URLs like https://example.com are linked via auto_link
  # - Email addresses are left as plain text
  BARE_URL_RE = /(?<![:\/@\w])((?:www\.)?[a-zA-Z0-9][a-zA-Z0-9\-]*\.[a-zA-Z]{2,12}(?:\/[^\s]*)?)(?![@\w])/

  def format_announcement_body(text)
    # Step 1: HTML-escape, then wrap bare domains in <a> tags (href has https://, display text unchanged)
    escaped = ERB::Util.html_escape(text)
    with_bare = escaped.gsub(BARE_URL_RE) do |match|
      %(<a href="https://#{match}" target="_blank" rel="noopener noreferrer">#{match}</a>)
    end.html_safe

    # Step 2: auto_link handles full https:// / http:// URLs; skip emails (link: :urls)
    linked = auto_link(with_bare, link: :urls, sanitize: false,
                       html: { target: '_blank', rel: 'noopener noreferrer' })

    simple_format(linked, {}, sanitize: false)
  end
end
