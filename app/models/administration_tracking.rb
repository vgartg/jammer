class AdministrationTracking < ApplicationRecord
  self.table_name = 'administration_tracking'
  belongs_to :admin, class_name: 'User'
end