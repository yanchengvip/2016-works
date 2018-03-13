class TaskProduct < ActiveRecord::Base
  self.table_name = 'task_products'
  include UUIDHelper
  belongs_to :task, foreign_key: 'TaskID'
end