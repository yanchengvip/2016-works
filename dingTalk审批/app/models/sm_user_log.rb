# 记录创建user
class SMUserLog < ActiveRecord::Base
    self.table_name = 'SMUserLogs'
    belongs_to :sm_user
    include UUIDHelper
end