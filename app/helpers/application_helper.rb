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
end
