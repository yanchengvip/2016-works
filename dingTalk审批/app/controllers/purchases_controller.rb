class PurchasesController < ApplicationController
  #before_action :one_level_approval, only: :one_level_purchases
  before_action :is_login

  #status -1:已删除,0：未审批，1：审批通过，2:审批拒绝，3：提交申请，4：待确认到货信息，5：带收货，6：待付款，7：打印完成，8：待总监审批（未审批），9：完成，10：待确认收货
  # 一级审批采购单列表
  def one_level_purchases
    # @is_menu不为空则当前用户有一级审批的权限
    @is_menu = User.approval_permissions current_user.ID,'', '/PurchaseExamine/Index'
    @purchases = []
    if @is_menu[:is_allowed]
      # 查询拥有审批哪些家公司的权限，返回companyID的数组
      companyIDArray = DataPrivilege.where(UserID: current_user.ID, TableName: 'FrameworkCompany').pluck(:RelateID)
      if companyIDArray.include?(nil)
        #如果存在companyIDArray，并且值为nil,则拥有所有公司审批的权限
        companyIDArray = FrameworkCompany.all.pluck(:ID)
      end
      @purchases = Purchase.includes(:framework_company, :depot, :purchase_details)
                       .where(Status: 3, CompanyID: companyIDArray)
                       .order(PurchaseCode: :desc)

    end

  end

  # 二级采购单审批列表
  def two_level_purchases
    # @is_menu不为空，则当前用户有二级审批的权限
    @is_menu = User.approval_permissions current_user.ID,'', '/PurchaseExamine/FinanceApproval'
    @two_purchases = []
    if @is_menu[:is_allowed]
      # 查询拥有审批哪些家公司的权限，返回companyID的数组
      companyIDArray = DataPrivilege.where(UserID: current_user.ID, TableName: 'FrameworkCompany').pluck(:RelateID)
      if companyIDArray.include?(nil)
        #如果存在companyIDArray，并且值为nil,则拥有所有公司审批的权限
        companyIDArray = FrameworkCompany.all.pluck(:ID)
      end
      @two_purchases = Purchase.includes(:framework_company, :depot, :purchase_logs, :purchase_details)
                           .where(Status: 8, CompanyID: companyIDArray)
                           .order(PurchaseCode: :desc)

    end

  end

  # 采购详情
  def purchase_details
    purchase_code = params[:purchase_code]
    @purchase = Purchase.includes(:framework_company, :depot, :purchase_details, :purchase_logs).where(PurchaseCode: purchase_code).first
    @purchase_detail = PurchaseDetail.includes(:product).where(PurchaseID: @purchase.ID)
  end

  # 修改采购单状态
  def update_status
    #数据库中Status 0：未审批，1：审批通过，2:审批拒绝,3：提交申请(一级审批),8：待总监审批（未审批，二级审批）
    status = params[:status]
    level = params[:level]
    purchase_code = params[:purchase_code]
    @purchase = Purchase.where({PurchaseCode: purchase_code}).first
    @client = Client.new
    old_status = @purchase.Status
    # 获取用户的钉钉user_id
    @user = User.where(ITCode: @purchase.CreateBy).first
    ding_id = @user.DingTalkUserID if !@user.nil?
    flag = ''
    content = '审批出现问题呀'
    if status.to_i == 0
      #审批拒绝
      ActiveRecord::Base.transaction do
        flag = @purchase.update_attributes!({Status: 2})
        content = "审核拒绝,【采购申请单号】:#{@purchase.PurchaseCode},【标题】：#{@purchase.Title},【审核人】:#{current_user.ITCode}"
        create_purchase_log @purchase.ID, '审核拒绝', '', current_user.ITCode, current_user.ITCode, 2
        response = @client.send_message_touser ding_id, content
        content = '审批拒绝'
      end
    elsif status.to_i == 1

      #审批通过
      if old_status.to_i != level
        render json: {status: 'error', content: '审批已经被他人通过，刷新页面查看'} and return
      end
      ActiveRecord::Base.transaction do
        case old_status.to_i
          when 3
            flag = @purchase.update_attributes!({Status: 8})
            content = "一级审核通过,【采购申请单号】:#{@purchase.PurchaseCode},【标题】：#{@purchase.Title},【审核人】:#{current_user.ITCode}"
            create_purchase_log @purchase.ID, '一级审核通过', '', current_user.ITCode, current_user.ITCode, 8
            response = @client.send_message_touser ding_id, content

          when 8
            flag = @purchase.update_attributes!({Status: 1})
            content = "审核通过,【采购申请单号】:#{@purchase.PurchaseCode},【标题】：#{@purchase.Title},【审核人】:#{current_user.ITCode}"
            create_purchase_log @purchase.ID, '审核通过', '', current_user.ITCode, current_user.ITCode, 1
            response = @client.send_message_touser ding_id, content
          else

        end

      end
    end

    if flag
      message = {status: 'ok', content: content}
    else
      message = {status: 'error', content: '修改失败'}
    end
    render json: message
  end

  private


  def create_purchase_log purchase_id, content, remark, create_by, update_by, type
    PurchaseLog.create!({PurchaseID: purchase_id, Content: content, Remark: remark, CreateBy: create_by, UpdateBy: update_by, Type: type})
  end


end
