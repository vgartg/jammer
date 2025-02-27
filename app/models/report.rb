class Report < ApplicationRecord
  belongs_to :reporter, class_name: 'User'
  belongs_to :reportable, polymorphic: true

  validates :reason, presence: true
  validates :reportable_id, uniqueness: { scope: %i[reportable_type reporter_id], message: 'Вы уже отправили жалобу на эту сущность' }

  enum :status, pending: 0, resolved: 1, rejected: 2
end
