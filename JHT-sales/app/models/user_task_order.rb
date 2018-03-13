class UserTaskOrder < ActiveRecord::Base
  self.table_name = 'user_task_orders'
  belongs_to :task, foreign_key: 'TaskID'
  belongs_to :user_task, foreign_key: 'UserTaskID'
  belongs_to :user_order, foreign_key: 'UserOrderID'
  include UUIDHelper
end
