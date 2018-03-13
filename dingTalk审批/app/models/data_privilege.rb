#用户仓库关联表
class DataPrivilege < ActiveRecord::Base
  self.table_name = 'dataprivileges'
  belongs_to :user,foreign_key: 'UserID'


end