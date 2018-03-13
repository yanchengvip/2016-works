#OrderStatus= -2:退货,-1:取消,0:保存,1:已提交,2:已确认,3:已发出,4:已收货,5:已收款,6:已关闭,7:待出库,8:已完成
class UserOrderLog < ActiveRecord::Base
  self.table_name = 'user_orders_logs'
  include UUIDHelper
  belongs_to :user_order,foreign_key: 'UserOrderID'
end