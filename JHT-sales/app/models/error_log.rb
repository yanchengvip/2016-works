class ErrorLog < ActiveRecord::Base
  self.table_name = 'error_logs'
  include UUIDHelper
end
