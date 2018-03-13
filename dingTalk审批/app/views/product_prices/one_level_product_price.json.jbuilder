#判断是否有审批的权限
if !@is_menu[:is_allowed]
  json.status 'error'
  json.message '没有此权限'
else
  json.status 'ok'
  json.data do
    json.array! @product_prices.each do |pp|
      json.product_price_id pp.product_price_id #商品采购表id
      json.product_price_status pp.product_price_status #审批状态
      json.name pp.Name #商品名称
      json.code pp.Code #商品编码
      json.before_purchase_price pp.before_purchase_price #调整前基准价
      json.after_purchase_price pp.after_purchase_price #调整后基准价
      json.before_sale_price pp.before_sale_price #调整前售价
      json.after_sale_price pp.after_sale_price #调整后售价
      json.is_timing_effect pp.IsTimingEffect #及时生效 或者延时生效
      json.effect_time pp.EffectTime ? pp.EffectTime.strftime('%Y-%m-%d %H:%M:%S') : '' #延时生效时间
      json.company pp.CompanyNameCN
      json.create_by pp.CreateBy #创建人
      json.remark pp.Remark #创建人创建的审核内容
      json.create_time pp.CreateTime ? pp.CreateTime.strftime('%Y-%m-%d %H:%M:%S') : ''
    end
  end
end
