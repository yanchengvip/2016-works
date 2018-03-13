#判断是否有审批的权限
if !@is_menu[:is_allowed]
  json.status 'error'
  json.message '没有此权限'
else
  json.status 'ok'
  json.data do
    json.array! @product_prices.each do |pp|
      json.product_price_id pp.ID #商品采购表id
      json.product_price_status pp.Status #审批状态
      json.name pp.product.Name #商品名称
      json.code pp.product.Code #商品编码
      json.before_purchase_price pp.product.PurchasePrice #调整前基准价
      json.after_purchase_price pp.PurchasePrice #调整后基准价
      json.before_sale_price pp.product.ProductPrice #调整前售价
      json.after_sale_price pp.Price #调整后售价
      json.is_timing_effect pp.IsTimingEffect #及时生效 或者延时生效
      json.effect_time pp.EffectTime ? pp.EffectTime.strftime('%Y-%m-%d %H:%M:%S') : '' #延时生效时间
      json.company pp.framework_company.CompanyNameCN
      json.create_by pp.CreateBy #创建人
      json.one_remark pp.one_level_product_price_logs.first ? pp.one_level_product_price_logs.desc_time.first.Remark : '无' #一级创建人创建的审批内容
      json.one_approval_person '' #一级审批人
      json.one_approval_time '' #一级审批时间
      if pp.two_level_product_price_logs.first.nil?
        json.two_approval_person ''
        json.two_remark ''
        json.two_approval_time ''
      else
        json.two_approval_person pp.two_level_product_price_logs.desc_time.first.CreateBy#二级审批人
        json.two_remark pp.two_level_product_price_logs.first.Remark ? pp.two_level_product_price_logs.desc_time.first.Remark : '无'  #二级创建人创建的审核内容
        json.two_approval_time pp.two_level_product_price_logs.first.CreateTime ?  pp.two_level_product_price_logs.desc_time.first.CreateTime.strftime('%Y-%m-%d %H:%M:%S') : '' #二级级审批时间
      end

      json.create_time pp.CreateTime ? pp.CreateTime.strftime('%Y-%m-%d %H:%M:%S') : ''
    end
  end
end


#判断是否有审批的权限
=begin
if @is_menu.empty?
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
      json.one_approval_person pp.one_approval_person #一级审批人
      json.two_approval_person pp.two_approval_person #二级审批人
      json.one_approval_time pp.one_approval_time ? pp.one_approval_time.strftime('%Y-%m-%d %H:%M:%S') : '' #一级审批时间
      json.two_approval_time pp.two_approval_time ? pp.two_approval_time.strftime('%Y-%m-%d %H:%M:%S') : '' #二级级审批时间
      json.create_time pp.CreateTime ? pp.CreateTime.strftime('%Y-%m-%d %H:%M:%S') : ''
    end
  end
end
=end

