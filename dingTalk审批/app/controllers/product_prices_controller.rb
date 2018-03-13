# 商品采购价格审批
class ProductPricesController < ApplicationController
  before_action :is_login




  def one_level_product_price
    # /Product/ProductPriceList
    @is_menu = User.approval_permissions current_user.ID,'/Product/ProductPriceList','/Product/ChangePriceAuditList1'
    @purchases = []
    if @is_menu[:is_allowed]

      # 查询拥有审批哪些家公司的权限，返回companyID的数组
      companyIDArray = DataPrivilege.where(UserID: current_user.ID, TableName: 'FrameworkCompany').pluck(:RelateID)
      select_options = "productprices.ID as product_price_id,productprices.status as product_price_status,productprices.Remark,productprices.CreateBy,productprices.CreateTime,productprices.PurchasePrice as after_purchase_price,
                        productprices.IsTimingEffect,productprices.EffectTime,productprices.Price as after_sale_price,
                        product.PurchasePrice as before_purchase_price,
                        product.Name,product.ProductPrice as before_sale_price,product.Code,company.CompanyNameCN"
      joins_options = "left join products as product on productprices.ProductID = product.ID
                       left join frameworkcompanies as company on product.CompanyID = company.ID"

      if companyIDArray.include?(nil)
        #如果存在companyIDArray，并且值为nil,则拥有所有公司审批的权限
        companyIDArray = FrameworkCompany.all.pluck(:ID)
      end

      @product_prices = ProductPrice.select(select_options)
                            .joins(joins_options)
                            .where("productprices.Status = 1 and product.CompanyID IN  (?)  ", companyIDArray)
                            .order(CreateTime: :desc)
    end


  end

  def two_level_product_price
    @is_menu = User.approval_permissions current_user.ID,'/Product/ProductPriceList','/Product/ChangePriceAuditList2'
    @purchases = []
    if @is_menu[:is_allowed]

      # 查询拥有审批哪些家公司的权限，返回companyID的数组
      companyIDArray = DataPrivilege.where(UserID: current_user.ID, TableName: 'FrameworkCompany').pluck(:RelateID)
      if companyIDArray.include?(nil)
        #如果存在companyIDArray，并且值为nil,则拥有所有公司审批的权限
        companyIDArray = FrameworkCompany.all.pluck(:ID)
      end
      @product_prices = ProductPrice.includes(:one_level_product_price_logs, :framework_company, :product)
                            .where("Products.CompanyID" => companyIDArray, Status: 2)
                            .order(CreateTime: :desc)
    end
  end


  def three_level_product_price
    @is_menu = User.approval_permissions current_user.ID,'/Product/ProductPriceList','/Product/ChangePriceAuditList3'
    @purchases = []
    if @is_menu[:is_allowed]

      # 查询拥有审批哪些家公司的权限，返回companyID的数组
      # companyIDArray = DataPrivilege.where(UserID: current_user.ID, TableName: 'FrameworkCompany').pluck(:RelateID)
      # select_options = "productprices.ID as product_price_id,productprices.status as product_price_status,productprices.Remark, productprices.CreateBy,productprices.CreateTime,productprices.PurchasePrice as after_purchase_price,
      #                   productprices.IsTimingEffect,productprices.EffectTime,productprices.Price as after_sale_price,product.ProductPrice as before_sale_price,
      #                   product.PurchasePrice as before_purchase_price,fkuser1.Name as one_approval_person,fkuser2.Name as two_approval_person,
      #                   pplog1.CreateTime as one_approval_time,pplog2.CreateTime as two_approval_time,
      #                   product.Name,product.Code,company.CompanyNameCN"
      # joins_options = "left join products as product on productprices.ProductID = product.ID
      #     left join frameworkcompanies as company on product.CompanyID = company.ID
      #     left join productpricelogs as pplog1 on pplog1.ProductPriceID = productprices.ID and pplog1.Type = 2
      #     left join productpricelogs as pplog2 on pplog2.ProductPriceID = productprices.ID and pplog2.Type = 3
      #     left join frameworkuser as fkuser1 on fkuser1.ITCode = pplog1.CreateBy
      #     left join frameworkuser as fkuser2 on fkuser2.ITCode = pplog2.CreateBy"
      #
      #
      #
      # if companyIDArray.include?(nil)
      #   #如果存在companyIDArray，并且值为nil,则拥有所有公司审批的权限
      #   companyIDArray = FrameworkCompany.all.pluck(:ID)
      # end
      # @product_prices = ProductPrice.select(select_options)
      #                       .joins(joins_options)
      #                       .where("productprices.Status = 3 and product.CompanyID IN  (?)  ", companyIDArray)
      #                       .order(CreateTime: :desc)

      companyIDArray = DataPrivilege.where(UserID: current_user.ID, TableName: 'FrameworkCompany').pluck(:RelateID)
      if companyIDArray.include?(nil)
        #如果存在companyIDArray，并且值为nil,则拥有所有公司审批的权限
        companyIDArray = FrameworkCompany.all.pluck(:ID)
      end
      @product_prices = ProductPrice.includes(:one_level_product_price_logs,:two_level_product_price_logs, :framework_company, :product)
                            .where("Products.CompanyID" => companyIDArray, Status: 3)
                            .order(CreateTime: :desc)


    end
  end

  def update_status
    # 数据库中Status: 0="保存",1='待一级审核',2= '待二级审核',3='待三级审核',10 = '已通过'
    status = params[:status]
    level = params[:level].to_i #判断在几级审核页面点击的通过
    product_price_id = params[:product_price_id]
    remark = params[:remark]
    if remark.nil? || remark == ''
      remark3 = '无'
    else
      remark3 =remark
    end
    remark_content = '审核出现点问题'
    @client = Client.new
    @product_price = ProductPrice.includes(:product).where(ID: product_price_id).first
    # 获取用户的钉钉user_id
    @user = User.where(ITCode: @product_price.CreateBy).first
    ding_id = @user.DingTalkUserID if !@user.nil?
    old_status = @product_price.Status
    is_timing_effect = @product_price.IsTimingEffect.to_i
    if status.to_i == 0
      # 审批驳回
      remark_content = "采购价格审核被驳回！【原因】:#{remark3},【审核人】：#{current_user.ITCode},【商品编号】:#{@product_price.product.Code},【商品名称】:#{@product_price.product.Name}"
      remark2 = "审核驳回:#{remark}"
      update_price_status 0, remark_content, product_price_id, ding_id, is_timing_effect,remark2,0

    elsif status.to_i == 1
      # 审批通过
      if old_status.to_i != level
          render json: {status: 'error', content: '审批已经被他人通过，刷新页面查看'} and return
      end
      case old_status.to_i
        when 1

          remark_content = "采购价格一级审核已通过，等待二级审核!【原因】: #{remark3},【审核人】：#{current_user.ITCode},【商品编号】:#{@product_price.product.Code},【商品名称】:#{@product_price.product.Name}"
          remark2 = "一级审核通过:#{remark}"
          update_price_status 2, remark_content, product_price_id, ding_id, is_timing_effect,remark2,1
        when 2
          remark_content = "采购价格二级审核已通过，等待三级审核!【原因】:'审核通过'+#{remark3},【审核人】：#{current_user.ITCode},【商品编号】:#{@product_price.product.Code},【商品名称】:#{@product_price.product.Name}"
          remark2 = "二级审核通过:#{remark}"
          update_price_status 3, remark_content, product_price_id,  ding_id, is_timing_effect,remark2,2

        when 3
          remark_content = "恭喜您，您提交的审核已通过!【原因】:#{remark3},【审核人】：#{current_user.ITCode},【商品编号】:#{@product_price.product.Code},【商品名称】:#{@product_price.product.Name}"
          remark2 = "三级审核通过:#{remark}"
          update_price_status 10, remark_content, product_price_id,  ding_id, is_timing_effect,remark2,3

        else

      end
    end
    if ding_id.nil?
      remark_content = remark_content + "因创建人钉钉未绑定，无法推送消息"
    end
    render json: {status: 'ok', content: remark_content}
  end

  private

  def create_price_log product_price_id, status, remark
    ProductPriceLog.create!({ProductPriceID: product_price_id, Type: status, Remark: remark, CreateBy: current_user.ITCode})
  end


  def update_price_status status2, remark_content, product_price_id, ding_id, is_timing_effect,remark,old_status
    ActiveRecord::Base.transaction do
      @product_price.update_attributes!({Status: status2})
      create_price_log product_price_id, old_status, remark
      @client.send_message_touser ding_id, remark_content
      # 价格状态为即时生效，则立刻修改相应价格
      #IsTimingEffect 0= '即时生效',1='延时生效',2='延时生效中的之前的过度中间状态'
      if !is_timing_effect.nil? && is_timing_effect != '' && is_timing_effect.to_i == 0 && status2.to_i == 10
        @product_price.product.update_attributes({ProductPrice: @product_price.Price, PurchasePrice: @product_price.PurchasePrice})
      end
    end
  end


end
