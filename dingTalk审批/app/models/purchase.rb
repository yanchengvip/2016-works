#status -1:已删除,0：未审批，1：审批通过，2:审批拒绝，3：提交申请(代表一级审核)，4：待确认到货信息，5：带收货，6：待付款，7：打印完成，8：待总监审批（未审批），9：完成，10：待确认收货
#payType:0:预付，1：票到付款，2：代销
# 采购单审批表
class Purchase < ActiveRecord::Base
  self.table_name = 'purchases'
  has_many :purchase_details, foreign_key: 'PurchaseID'
  belongs_to :depot, foreign_key: 'DepotID'
  belongs_to :framework_company, foreign_key: 'CompanyID'
  has_many :purchase_logs,->{where(Type:8).order("CreateTime desc")}, foreign_key: 'PurchaseID'
end