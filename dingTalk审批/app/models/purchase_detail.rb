# 采购单审批详情表
class PurchaseDetail < ActiveRecord::Base
  self.table_name = 'purchasedetails'
  belongs_to :purchase, foreign_key: 'PurchaseID'
  belongs_to :product,foreign_key: 'ProductID'
end