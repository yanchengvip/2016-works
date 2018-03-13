# 用户角色关联表
class FrameworkUserRole < ActiveRecord::Base
  self.table_name = 'frameworkuserrole'
  belongs_to :user,foreign_key: 'FrameworkUserBase_ID'
  belongs_to :framework_role,foreign_key: 'FrameworkRole_ID'
end