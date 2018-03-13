# encoding: UTF-8
class UserOrdersController < ApplicationController
  before_action :is_login, except: [:order_handling, :scan_qrcode_order, :qrcode_bind_order,:split_order]

  # 获取用户的订单列表
  def user_order_list
    page = params[:page] ||= 1
    per_page = params[:per_page] ||= 30
    #@user_orders = current_user.user_orders.includes(:user_order_logs).paginate(page: page, per_page: per_page)
    @user_orders = UserOrder.query_orders current_user, params
  end

  # 订单信息
  def order_details
    user_order_id = params[:user_order_id]
    @user_order = UserOrder.includes(:user_order_logs, :tasks).where(ID: user_order_id).first

    if @user_order.UserID == current_user.ID
      @order_tasks = @user_order.tasks.where(TaskObject: [0, 1])
    else
      # 说明是推广业务员查看普通业务员的订单详情
      @order_tasks = @user_order.tasks.where(TaskObject: 2)
    end

  end

  #订单处理,根据订单状态改变,操作用户所得佣金等相应数化，包括退货，取消订单等
  def order_handling
    order = params['data']
    order_id = order['OrderID']
    order_status = order['OrderStatus'].to_i
    record_time = order['RecordTime'] #操作时间
    cost_item = order['CostItem'] #订单金额
    platform = order['From'].to_i
    user_order = UserOrder.where(OrderID: order_id, Platform: platform).first

    if user_order.nil?
      render json: {status: 0, message: '此订单没有被绑定'} and return
    end

    # 根据订单状态操作
    case order_status
      when -2
        # 退货
        content = "订单有退货! 订单号:#{user_order.OrderCode}"
        response = UserOrder.order_return user_order.UserID, order
      #WeixinMenu.send_weixin_message_by_order order_id, 8, content
      when -1
        #订单取消
        content = "订单取消! 订单号:#{user_order.OrderCode}"
        response = UserOrder.order_return user_order.UserID, order
      #WeixinMenu.send_weixin_message_by_order order_id, 8, content
      when 1
        # order_log记录订单的状态操作变化
        content = "订单已提交! 订单号:#{user_order.OrderCode}"
        response = create_order_log user_order, order_id, order_status, record_time, cost_item, content
      when 3
        content = "订单已发货! 订单号:#{user_order.OrderCode}"
        #保存司机姓名电话
        user_order.update_attributes(DriverName: order['DriverName'], DriverMobile: order['DriveMobile'])
        response = create_order_log user_order, order_id, order_status, record_time, cost_item, content
      when 5
        content = "订单已收款! 订单号:#{user_order.OrderCode}"
        #保存订单支付方式
        user_order.update_attributes(ReceivePriceType: order['PayType'])
        response = create_order_log user_order, order_id, order_status, record_time, cost_item, content
      when 8
        content = "订单已完成! 订单号:#{user_order.OrderCode}"

        response = create_order_log user_order, order_id, order_status, record_time, cost_item, content
    end

    render json: response
  end


  # 扫描订单的二维码
  def scan_qrcode_order
    redirect_to $weixin.authorize_url(Settings.weixin.qrcode_bind_order+"?qrcode=#{params[:qrcode]}")
  end

  # 根据扫描的订单二维码绑定订单
  def qrcode_bind_order
    code = params[:code]
    qrcode = params[:qrcode]
    openid = User.get_openid code
    @user = User.find_by({OpenID: openid}) if !openid.nil?
    message = @user.get_order_by_platform qrcode
    render json: message
  end


  #订单分单,一个订单拆分多个
  def split_order
    parent_order = params['parentOrder'] #母订单
    sub_orders = params['data'] #分单后的子订单
    message = UserOrder.split_order_handling parent_order,sub_orders

    render json: message
  end


  private

  # 记录订单状态，并且向相应业务员推送微信消息
  def create_order_log user_order, order_id, order_status, record_time, cost_item, content

    message = {status: 0, message: '保存订单状态日志操作失败'}
    ActiveRecord::Base.transaction do
      user_order.user_order_logs.create(OrderID: order_id, OrderStatus: order_status, RecordTime: record_time, Money: cost_item)
      user_order.update_attributes(OrderStatus: order_status) #修改订单的状态
      response = WeixinMenu.send_weixin_message_by_order order_id, 8, content
      message = {status: 1, message: '保存订单状态日志操作成功'}
      en_msg = response.en_msg
      result = response.result
      cn_msg = response.cn_msg
      message = message.merge({en_msg: en_msg, result: result, cn_msg: cn_msg})
    end
    return message
  end
end
