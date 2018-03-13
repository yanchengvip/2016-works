# 记录创建user
class UserLog < ActiveRecord::Base
    self.table_name = 'userlogs'
    belongs_to :user
    include UUIDHelper
end