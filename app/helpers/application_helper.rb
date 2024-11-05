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
end
