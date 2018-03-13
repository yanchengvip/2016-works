#审批详情
json.status 'ok'
json.data do
  json.purchase_code @purchase.PurchaseCode
  json.title @purchase.Title
  json.company @purchase.depot.Name
  json.supplier_name @purchase.SupplierName
  json.total_purchase @purchase.purchase_details.sum('ProductTotalPrice') #采购单总价
  case  @purchase.PayType.to_i
    when 0
      json.pay_type '预付'
    when 1
      json.pay_type '票到付款'
    when 2
      json.pay_type '代销'
    else
      json.pay_type '无'
  end
  json.status @purchase.Status
   if @purchase.Status.to_i == 3
     # 一级审核没有审批人
     json.one_approval_person '无'
     json.one_approval_time '无'
   else
     json.one_approval_person @purchase.purchase_logs.first ? @purchase.purchase_logs.desc_time.first.CreateBy : '' #一级审批人
     json.one_approval_time  @purchase.purchase_logs.first ? @purchase.purchase_logs.desc_time.first.CreateTime.strftime('%Y-%m-%d %H:%M:%S') : '' #一级审批时间
   end

  #是否代销，第三方平台业务，0：false,1:ture
  if @purchase.IsSaleSyProxy == "\u0000"
    json.is_sale_sy_proxy 0
  end
  if @purchase.IsSaleSyProxy == "\u0001"
    json.is_sale_sy_proxy 1
  end

  json.create_by @purchase.CreateBy
  json.create_time @purchase.CreateTime ? @purchase.CreateTime.strftime("%Y-%m-%d %H:%M:%S") : ''
  json.purchase_products do
    json.array! @purchase_detail do |detail|
      json.name detail.ProductName
      json.specification detail.Specification
      json.code detail.product.Code
      json.before_purchase_price detail.BeforePurchasePrice #上次采购价
      json.average_price detail.product.MovingAverage #平均采购价/移动加权平均数
      json.product_price detail.ProductPrice #采购单价
      json.product_total_price detail.ProductTotalPrice #产品总价（采购数量*单价）
      json.original_price detail.product.PurchasePrice #采购基价
      json.product_number detail.ProductNumber #采购数量
      json.stock detail.Stock #库存剩余
      json.xs_number detail.XsNumber.to_i #七日销量
      json.max_sale_amount ''
      if detail.XsNumber.to_i != 0
        json.service_point (detail.Stock.to_f/detail.XsNumber.to_i).to_f.round(4)  #存销比
      else
        json.service_point 0  #存销比
      end

    end
  end


end