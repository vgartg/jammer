module Sortable
  extend ActiveSupport::Concern

  private

  def sort_relation(relation, sortable_columns:, default: 'id')
    sort_by = sortable_columns.include?(params[:sort_by]) ? params[:sort_by] : default
    direction = params[:direction] == 'desc' ? :desc : :asc
    relation.order(sort_by => direction)
  end
end
