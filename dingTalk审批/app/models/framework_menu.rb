# 菜单表
class FrameworkMenu < ActiveRecord::Base
  self.table_name = 'frameworkmenus'
  has_many :function_privileages, foreign_key: 'MenuItemId'
  has_many :framework_roles,through: 'function_privileages',foreign_key: 'MenuItemId'
  belongs_to :parent_menu, class_name: 'FrameworkMenu', foreign_key: 'ParentID'
end