# 角色表
class FrameworkRole < ActiveRecord::Base
  self.table_name = 'frameworkroles'
  has_many :framework_user_roles, foreign_key: 'FrameworkRole_ID'
  has_many :users, through: 'framework_user_roles', foreign_key: 'FrameworkRole_ID'
  has_many :function_privileages, foreign_key: 'RoleID'
  has_many :framework_menus, through: 'function_privileages', foreign_key: 'RoleID'
end