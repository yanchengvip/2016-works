# 采购单审批表
class PurchaseLog < ActiveRecord::Base
  self.table_name = 'purchaselogs'
  include UUIDHelper
  belongs_to :purchase, foreign_key: 'PurchaseID'
  scope :desc_time,-> {order(CreateTime: :desc)}
end