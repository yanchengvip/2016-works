#判断是否有审批的权限
if !@is_menu[:is_allowed]
  json.status 'error'
  json.message '没有此权限'
else

  json.status 'ok'
  json.data do
    json.array! @two_purchases.each do |two_pur|
      json.purchase_code two_pur.PurchaseCode
      json.title two_pur.Title
      json.company two_pur.framework_company.CompanyNameCN
      json.supplier_name two_pur.SupplierName
      json.total_purchase two_pur.purchase_details.sum('ProductTotalPrice')#采购单总价
      case  two_pur.PayType.to_i
        when 0
          json.pay_type '预付'
        when 1
          json.pay_type '票到付款'
        when 2
          json.pay_type '代销'
        else
          json.pay_type '无'
      end
      json.status two_pur.Status
      #是否代销，第三方平台业务，0：false,1:ture
      if two_pur.IsSaleSyProxy == "\u0000"
        json.is_sale_sy_proxy 0
      end
      if two_pur.IsSaleSyProxy == "\u0001"
        json.is_sale_sy_proxy 1
      end
      json.one_approval_person two_pur.purchase_logs.first ? two_pur.purchase_logs.desc_time.first.CreateBy : '' #一级审批人
      json.one_approval_time two_pur.purchase_logs.first ? two_pur.purchase_logs.desc_time.first.CreateTime.strftime("%Y-%m-%d %H:%M:%S") : ''#一级审批时间
      json.create_by two_pur.CreateBy
      json.create_time two_pur.CreateTime.strftime("%Y-%m-%d %H:%M:%S")
    end
  end

end
