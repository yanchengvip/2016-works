module UserOrders
  module SplitOrderHelper
    extend ActiveSupport::Concern


    # 订单分单处理
    def UserOrder.split_order_handling parent_order,sub_orders
      message = {status: 50, message: '开始分单绑定...'}
      #parent_order = params['parentOrder'] #母订单
      parent_order_id = parent_order['OrderID']
      #sub_orders = params['data'] #分单后的子订单
      parent_user_order = UserOrder.find_by(OrderID: parent_order_id)

      return {status: 1, message: '订单未绑定'} if parent_user_order.nil?

      #分单后,绑定的母单按原来价钱取消,(分担后金额可能会变)
      parent_order['CostItem'] = parent_user_order.OrderMoney.to_f
      parent_order['OrderStatus'] = -3
      #ActiveRecord::Base.transaction do
        #ActiveRecord::StatementInvalid (Mysql2::Error: Lock wait timeout exceeded; try restarting transaction:
        #取消母订单
        UserOrder.order_return parent_user_order.UserID, parent_order
        #parent_user_order.update_attributes({OrderStatus: -3})

        #重新绑定拆分后的子订单
        sub_orders.each_with_index { |sub_order, index|
          if index > 0
            Thread.new{
              sleep index
              parent_user_order.user.bind_order sub_order
            }
          else
            result = parent_user_order.user.bind_order sub_order
            if result[:status].to_i == 1 #防止后台没有配置任务,友好提示
              message = {status: 70, message: '网络不稳定,请稍后再试'}
            else
              message = {status: 30, message: result[:message]}
            end
          end
        }

      #end

      return message
    end


  end
end
