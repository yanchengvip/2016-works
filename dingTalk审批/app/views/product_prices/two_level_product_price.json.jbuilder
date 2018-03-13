if !@is_menu[:is_allowed]
  json.status 'error'
  json.message '没有此权限'
else
  json.status 'ok'
  json.data do
    json.array! @product_prices.each do |pp|
      json.product_price_id  pp.ID #商品采购表id
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
      if pp.one_level_product_price_logs.first.nil?
        json.one_remark '无'
        json.one_approval_person '无'
        json.one_approval_time '无'
      else
        json.one_remark pp.one_level_product_price_logs.first.Remark ? pp.one_level_product_price_logs.desc_time.first.Remark : '无' #一级创建人创建的审批内容
        json.one_approval_person pp.one_level_product_price_logs.first.CreateBy ? pp.one_level_product_price_logs.desc_time.first.CreateBy : '无' #一级审批人
        json.one_approval_time pp.one_level_product_price_logs.first.CreateTime ?  pp.one_level_product_price_logs.desc_time.first.CreateTime.strftime('%Y-%m-%d %H:%M:%S') : '' #一级审批时间
      end

      json.create_time pp.CreateTime ? pp.CreateTime.strftime('%Y-%m-%d %H:%M:%S') : '' #审批创建时间
    end
  end
end