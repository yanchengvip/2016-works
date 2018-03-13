#OrderStatus= -3:分单取消(一个母订单分为多个子订单), -2:退货,-1:取消,0:保存(无退货和取消)，和user_order_log里面的orderstatus值不同
# OrderMoney为总价格，包括退货的钱;ReturnMoney为退货的金额
class UserOrder < ActiveRecord::Base
  self.table_name = 'user_orders'
  include UUIDHelper
  include UserOrders::SplitOrderHelper

  belongs_to :user, foreign_key: 'UserID'
  has_many :user_order_logs, -> { order('CreateTime desc') }, foreign_key: 'UserOrderID'
  has_many :user_task_orders, foreign_key: 'UserOrderID'
  has_many :tasks, through: :user_task_orders, foreign_key: 'UserOrderID'

  after_save :update_time


  # 订单存在退货/取消的情况
  def self.order_return user_id, order
    order_id = order['OrderID']
    products = order['products']
    order_city = order['BelongCityID']
    platform = order['From'].to_i
    user_task_order_arr = []
    user_task_arr = []
    user_task_log_arr = []
    cost_item = order['CostItem'].to_f #订单总金额
    order_status = order['OrderStatus'].to_i
    order_return_money = 0
    return_products_names = order['ProductName'] #退货的所有产品名称
    # 获取订单对应进货宝平台任务的城市ID
    task_city = Task.task_city order_city, platform
    current_user = User.find(user_id)
    user_relation = current_user.user_relation
    if user_relation.present?
      extend_user = user_relation.user #推广员
    end
    @user_order = UserOrder.where(UserID: user_id, OrderID: order_id).first
    return {status: 4,message: '订单已接处理过了取消,不能重复取消'} if @user_order.OrderStatus == -1

    if [-1,-3].include? order_status
      # 订单取消
      order_return_money = cost_item
      user_order_atrr = {ReturnMoney: order_return_money, OrderStatus: order_status}
    end
    if order_status == -2
      # 订单退货
      products.each do |product|
        order_return_money += product['ReturnNumber'].to_i * product['ProductPrice'].to_f
      end
      order_return_money += @user_order.ReturnMoney.to_f
      user_order_atrr = {ReturnMoney: order_return_money, OrderStatus: order_status, IsHaveReturn: true}
    end


    user_order_logs_atrr = {OrderID: order['OrderID'], OrderStatus: order['OrderStatus'], RecordTime: order['RecordTime'], Money: order['CostItem'], ReturnMoney: order_return_money}

    if !task_city[:status]
      @user_order.update_attributes(user_order_atrr) #修改订单退货金额,但是user_order中的OrderMoney为总价格，包括退货的钱
      @user_order.user_order_logs.create(user_order_logs_atrr)
      no_order_message = {status: 3, message: '该用户没有订单所在城市的任务'}
      return no_order_message
    end

    # 此订单关联的所有任务
    tasks = @user_order.tasks.order('Type asc')
    tasks.each do |task|
      # 如果订单取消时，超过了任务结束时间+清算时间，则不做任何处理
      next if task.EndTime + task.BalanceDays.days < Time.new
      params = {
          task_id: task.ID,
          user_id: user_id,
          order_status: order_status
      }

      if [4, 5].include?(task.Type.to_i)
        @user_task_order = UserTaskOrder.where(UserID: extend_user.ID, TaskID: task.ID, OrderID: order_id).first
      else
        @user_task_order = UserTaskOrder.where(UserID: user_id, TaskID: task.ID, OrderID: order_id).first
      end


      # 如果@user_task_order不存在，则只修改UserOrder相关信息
      if @user_task_order.present?
        user_task_order_amount = @user_task_order.Amount
        old_return_amount = @user_task_order.ReturnAmount.to_f
        case task.Type.to_i
          when 0, 1
            # 如果为基础佣金，则Amount和ReturnAmount记录钱数
            # 订单达成金额任务
            params = params.merge(amount: -order_return_money, return_amount: order_return_money)
            user_task_attrs, user_task_logs, option_params = UserTask.update_current_reward params
            user_task_order = {Amount: user_task_order_amount - order_return_money, ReturnAmount: old_return_amount + order_return_money, ID: @user_task_order.ID}
            user_task_order_arr.push(user_task_order)
            user_task_arr.push(user_task_attrs)
            user_task_log_arr.push(user_task_logs)
          when 2
            #订单数量任务  退货情况下不作处理
            if [-1,-3].include? order_status
              return_amount = 1 #订单数量
              params = params.merge(amount: -return_amount, return_amount: return_amount)
              user_task_attrs, user_task_logs, option_params = UserTask.update_current_reward params
              user_task_order = {Amount: user_task_order_amount - return_amount, ReturnAmount: old_return_amount + return_amount, ID: @user_task_order.ID}
              user_task_order_arr.push(user_task_order)
              user_task_arr.push(user_task_attrs)
              user_task_log_arr.push(user_task_logs)
            end

          when 3
            #订单达成单商品销量任务
            products.each do |product|
              if product['ProductInfoID'] == task.task_product.ProductID
                if order_status == -1
                  #取消订单
                  return_number = product['Quantity'].to_i
                end
                if order_status == -2
                  #退货
                  return_number = product['ReturnNumber'].to_i
                end
                params = params.merge(amount: -return_number, return_amount: return_number)
                user_task_attrs, user_task_logs, option_params = UserTask.update_current_reward params
                user_task_order = {Amount: user_task_order_amount - return_number, ReturnAmount: old_return_amount + return_number, ID: @user_task_order.ID}
                user_task_order_arr.push(user_task_order)
                user_task_arr.push(user_task_attrs)
                user_task_log_arr.push(user_task_logs)
              end

            end
          when 4, 5
            #推广员 手下用户订单金额的任务
            #推广员 手下用户订单佣金任务
            next if extend_user.nil? #没有关联推广员
            @extend_user_task_order = UserTaskOrder.where(UserID: extend_user.ID, TaskID: task.ID, OrderID: @user_order.OrderID).first
            next if @extend_user_task_order.nil?
            params2 = {
                task_id: task.ID,
                user_id: extend_user.ID,
                amount: -order_return_money,
                return_amount: order_return_money,
                order_status: order_status
            }
            user_task_attrs, user_task_logs, option_params = UserTask.update_current_reward params2
            user_task_order_arr.push(Amount: user_task_order_amount - order_return_money, ReturnAmount: old_return_amount + order_return_money, ID: @extend_user_task_order.ID)
            user_task_arr.push(user_task_attrs)
            user_task_log_arr.push(user_task_logs)

        end

      end
    end
    if order_status == -3
      #订单分单的取消,不需要通知用户
      weixin_messages = []
    else

      weixin_messages = weixin_template_content current_user, order_status, @user_order, extend_user, return_products_names, cost_item

    end
    result = UserOrder.return_order_save @user_order, user_order_atrr, user_order_logs_atrr, user_task_arr, user_task_order_arr, user_task_log_arr, weixin_messages, order_status

    if result[:status] == 'ok'
      message = {status: 1, message: '订单处理成功'}
    end
    if result[:status] == 'error'
      message = {status: 2, message: result[:message]}
    end

    return message
  end


  def self.query_orders current_user, params
    page = params[:page] ||= 1
    per_page = params[:per_page] ||= 30
    order_code = params[:order_code]
    ship_tel = params[:ship_tel]
    start_time = params[:start_time]
    end_time = params[:end_time]

    conditions = ['UserID = ? ']
    values = [current_user.ID]

    if order_code.present?
      conditions << 'OrderCode like ?'
      values << '%' + order_code + '%'
    end

    if ship_tel.present?
      conditions << 'ShipTel = ?'
      values << ship_tel
    end

    if start_time.present?
      conditions << 'CreateTime >= ? '
      values << start_time
    end

    if end_time.present?
      conditions << 'CreateTime <= ? '
      values << end_time + ' 23:59:59'
    end

    if conditions.length ==1
      # 没有条件则默认查询最新20条,不显示状态为-3的订单
      @orders = UserOrder.includes(:tasks, :user_order_logs).where(conditions.join(' and '), *values).where.not(OrderStatus: -3)
                    .order('CreateTime desc')
                    .paginate(page: page, per_page: per_page)
    else
      @orders = UserOrder.includes(:tasks, :user_order_logs).where(conditions.join(' and '), *values).where.not(OrderStatus: -3)
                    .order('CreateTime desc')
    end
    return @orders

  end


  private

  # 退货保存相关信息
  def self.return_order_save user_order, user_order_atrr, user_order_logs_atrr, user_task_arr, user_task_order_arr, user_task_log_arr, weixin_messages, order_status
    ActiveRecord::Base.transaction do
      user_order.update_attributes(user_order_atrr) #修改订单退货金额,但是user_order中的OrderMoney为总价格，包括退货的钱
      user_order.user_order_logs.create(user_order_logs_atrr)
      # 修改UserTaskOrder值
      user_task_order_arrs = []
      user_task_arrs = []
      user_task_log_arrs = []

      user_task_arr.each do |user_task_atrr|
        user_task_arrs << UserTask.new(user_task_atrr)
      end
      if order_status.to_i == -1
        #订单取消
        UserTask.import user_task_arrs, on_duplicate_key_update: [:CurrentAmount, :CurrentStep, :CurrentReward, :CancelAmount, :CancelReward, :IsHaveCancel]
      elsif order_status.to_i == -2
        #订单退货
        UserTask.import user_task_arrs, on_duplicate_key_update: [:CurrentAmount, :CurrentStep, :CurrentReward, :ReturnAmount, :ReturnReward, :IsHaveReturn]
      elsif order_status.to_i == -3
        #分单时,母单取消
        UserTask.import user_task_arrs, on_duplicate_key_update: [:CurrentAmount, :CurrentStep, :CurrentReward]
      end


      if [-1,-3].include? order_status.to_i
        #order_status = -1代表订单取消,-3代表分单取消
        user_task_order_arr.each do |user_task_order_atrr|
          UserTaskOrder.find(user_task_order_atrr[:ID]).destroy
        end
      elsif order_status.to_i == -2
        #order_status = -2代表订单退货
        user_task_order_arr.each do |user_task_order_atrr|
          user_task_order_arrs << UserTaskOrder.new(user_task_order_atrr)
        end
        UserTaskOrder.import user_task_order_arrs, on_duplicate_key_update: [:Amount, :ReturnAmount]
      end


      user_task_log_arr.each do |user_task_log_atrr|
        user_task_log_arrs << UserTaskLog.new(user_task_log_atrr)
      end
      user_task_log_arrs.each do |user_task_log_atrr|
        user_task_log_atrr.run_callbacks(:create) { false }
      end
      UserTaskLog.import user_task_log_arrs

    end

    begin
      # 发送退货模板消息
      if weixin_messages[:normal_user_weixin_message].present?
        WeixinMenu.send_template_message weixin_messages[:normal_user_weixin_message]
      end

      if weixin_messages[:extend_user_weixin_message].present?
        WeixinMenu.send_template_message weixin_messages[:extend_user_weixin_message]
      end
    rescue => e
      return {status: 'error', message: "退货/取消订单通知用户微信发送失败;orderid===#{user_order.OrderID};微信发送失败原因===#{e.message}"}
    end

    return {status: 'ok'}

  end


  # 微信消息内容
  def self.weixin_template_content current_user, order_status, user_order, extend_user, return_products_names, cost_item
    if order_status.to_i == -1
      # 订单取消
      weixin_content = {
          status: 4,
          normal_user_content: "订单取消信息",
          extent_user_content: "您关联的手下业务员【#{current_user.Name}】有取消订单"
      }
    end
    if order_status.to_i == -2
      weixin_content = {
          status: 3,
          normal_user_content: "订单退货信息",
          extent_user_content: "您关联的手下业务员【#{current_user.Name}】有退货订单"
      }
    end
    # 普通用户的发送订单取消 模板消息
    normal_user_weixin_message = {
        openid: current_user.OpenID,
        status: weixin_content[:status],
        content: weixin_content[:normal_user_content],
        order_code: user_order.OrderCode,
        order_money: cost_item,
        ship_name: user_order.ShipName,
        ship_tel: user_order.ShipTel,
        return_products_names: return_products_names

    }
    if !extend_user.nil?
      #推广员模板信息
      extend_userweixin_message = {
          openid: extend_user.OpenID,
          status: weixin_content[:status],
          content: weixin_content[:extent_user_content],
          order_code: user_order.OrderCode,
          order_money: cost_item,
          ship_name: user_order.ShipName,
          ship_tel: user_order.ShipTel,
          normal_name: current_user.Name,
          normal_id: current_user.ID

      }
    end
    weixin_messages = {
        normal_user_weixin_message: normal_user_weixin_message,
        extend_user_weixin_message: extend_userweixin_message
    }
    return weixin_messages
  end

  def update_time
    self.UpdateTime = Time.now
  end


end
