# 用户采购商品价格审批表
# status: 0="保存",1='待一级审核',2= '待二级审核',3='待三级审核',10 = '已通过'
#IsTimingEffect 0= '即时生效',1='延时生效',2='延时生效中的之前的过度中间状态'
class ProductPrice < ActiveRecord::Base
  self.table_name = 'productprices'
  belongs_to :product, foreign_key: 'ProductID'
  has_many :one_level_product_price_logs, -> { where(Type: 1) }, class_name: 'ProductPriceLog', foreign_key: 'ProductPriceID' #一级审批通过的记录
  has_many :two_level_product_price_logs, -> { where(Type: 2) }, class_name: 'ProductPriceLog', foreign_key: 'ProductPriceID' #二级审批通过的记录
  # has_many :one_level_product_price_logs,->{where(Type:2).order(CreateTime: :desc)},foreign_key: 'ProductPriceID'
  has_one :framework_company, through: 'product', foreign_key: 'ProductID'
end