#判断是否有审批的权限
if !@is_menu[:is_allowed]
  json.status 'error'
  json.message '没有此权限'
else
  json.status 'ok'
  json.data do
    json.array! @purchases.each do |pur|
      json.purchase_code pur.PurchaseCode
      json.title pur.Title
      json.company pur.depot.Name
      json.supplier_name pur.SupplierName
      json.total_purchase pur.purchase_details.sum('ProductTotalPrice')#采购单总价
      case  pur.PayType.to_i
        when 0
          json.pay_type '预付'
        when 1
          json.pay_type '票到付款'
        when 2
          json.pay_type '代销'
        else
          json.pay_type '无'
      end
      json.status pur.Status
      #是否代销，第三方平台业务，0：false,1:ture
      if pur.IsSaleSyProxy == "\u0000"
        json.is_sale_sy_proxy 0
      end
      if pur.IsSaleSyProxy == "\u0001"
        json.is_sale_sy_proxy 1
      end
      json.create_by pur.CreateBy
      json.create_time pur.CreateTime ? pur.CreateTime.strftime("%Y-%m-%d %H:%M:%S") : ''
    end
  end
end




