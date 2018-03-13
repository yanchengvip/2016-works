# 角色菜单关联表
class FunctionPrivileage < ActiveRecord::Base
  self.table_name = 'functionprivileges'

  belongs_to :framework_menu, foreign_key: 'MenuItemId'
  belongs_to :framework_role, foreign_key: 'RoleID'
end