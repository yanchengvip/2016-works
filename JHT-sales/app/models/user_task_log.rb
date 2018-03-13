class UserTaskLog < ActiveRecord::Base
  self.table_name = 'user_tasks_logs'
  include UUIDHelper
  belongs_to :user_task,foreign_key: 'UserTaskID'
end