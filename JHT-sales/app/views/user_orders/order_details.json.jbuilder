if @user_order.nil?
  json.status 'error'
  json.data []
else
  return_order_info = {}
  json.status 'ok'
  json.data do
    json.user_order_id @user_order.ID
    json.order_code @user_order.OrderCode
    json.ship_name @user_order.ShipName #接货人
    json.ship_tel @user_order.ShipTel #接货人电话
    json.receive_price_type @user_order.ReceivePriceType #支付方式
    json.driver_name @user_order.DriverName #司机姓名
    json.driver_mobile @user_order.DriverMobile#司机电话
    json.order_money @user_order.OrderMoney
    json.is_have_return @user_order.IsHaveReturn #是否有退货 true/false
    json.order_status @user_order.user_order_logs.empty? ? '' : @user_order.user_order_logs.first.OrderStatus
    # 订单的状态追踪历史记录
    json.order_history do
      json.array! @user_order.user_order_logs.each do |log|

        case log.OrderStatus.to_i
          when -2
            # json.user_order_log_id log.ID
            # json.order_status_num -2 #订单状态
            # json.order_status '订单退货'
            # json.return_money @user_order.ReturnMoney #退货金额
            # json.balance @user_order.OrderMoney.to_f - @user_order.ReturnMoney.to_f #退货后的订单总价
            # json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
            return_order_info = {
                user_order_log_id: log.ID,
                order_status_num: -2, #订单状态
                order_status: '订单退货',
                return_money: @user_order.ReturnMoney, #退货金额
                balance: @user_order.OrderMoney.to_f - @user_order.ReturnMoney.to_f, #退货后的订单总价
                record_time: log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
            }
          when 1
            json.user_order_log_id log.ID
            json.order_status_num 1 #订单状态
            json.order_status '订单提交'
            json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
          when 3
            json.user_order_log_id log.ID
            json.order_status_num 3
            json.order_status '货物已发出'
            json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
          when 5
            json.user_order_log_id log.ID
            json.order_status_num 5
            json.order_status '支付成功'
            json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
          when 8
            json.user_order_log_id log.ID
            json.order_status_num 8
            json.order_status '订单完成'
            json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
            json.return_order_info return_order_info #退货信息

        end
      end
    end

    json.order_tasks do
      json.array! @order_tasks.each do |task|
        json.id task.ID
        json.title task.Title
        json.task_logo Settings.qiniu.qiniu_base_url + task.LogoQiNiu.to_s
        json.type task.Type
        json.begin_time task.BeginTime.strftime('%Y-%m-%d %H:%M') #任务开始时间
        json.end_time task.EndTime.strftime('%Y-%m-%d %H:%M')  #任务结束时间
      end
    end
  end

end