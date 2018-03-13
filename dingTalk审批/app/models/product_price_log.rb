#审批日志  remark = "审批人的批注",create_by= '审批人'
class ProductPriceLog < ActiveRecord::Base
  self.table_name = 'productpricelogs'
  include UUIDHelper
  belongs_to :product_price, foreign_key: 'ProductPriceID'
  scope :desc_time,-> {order(CreateTime: :desc)}
end