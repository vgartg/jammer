module ApplicationHelper

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

  def notification_message(notification)
    case notification.action
    when 'accepted_friendship'
      'принял заявку в друзья'
    when 'sent_friend_request'
      'отправил запрос в друзья'
    when 'awaiting game moderation'
      '- игра ожидает модерацию'
    when 'awaiting jam moderation'
      '- джем ожидает модерацию'
    when 'game change status after moderation'
      '- статус игры изменен после модерации'
    when 'jam change status after moderation'
      '- статус джема изменен после модерации'
    else
      notification.action
    end
  end
end
