if @user_orders.empty?
  json.status 'error'
  json.data []
else
  json.status 'ok'
  json.data do
    json.array! @user_orders.each do |uo|
      json.user_order_id uo.ID
      json.order_code uo.OrderCode
      json.ship_name uo.ShipName #接货人
      json.ship_tel uo.ShipTel #接货人电话
      json.order_money uo.OrderMoney #订单原价，包括退货后的钱
      json.tasks_num uo.tasks.where(TaskObject: [0,1]).length #订单关联的任务数量
      json.order_status uo.user_order_logs.empty? ? '' : uo.user_order_logs.first.OrderStatus
      # 订单的状态追踪历史记录
      json.order_history do
        json.array! uo.user_order_logs.each do |log|
          case log.OrderStatus.to_i
            when -2
              #订单退货
              json.user_order_log_id log.ID
              json.order_status_num -2 #订单状态
              json.order_status '订单退货'
              json.return_money uo.ReturnMoney
              json.balance uo.OrderMoney.to_f - uo.ReturnMoney.to_f #退货后的订单总价
              json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
            when 1
              #订单提交
              json.user_order_log_id log.ID
              json.order_status_num 1 #订单状态
              json.order_status '订单提交'
              json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
            when 3
              #货物已发出
              json.user_order_log_id log.ID
              json.order_status_num 3
              json.order_status '货物已发出'
              json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
            when 5
              #支付成功
              json.user_order_log_id log.ID
              json.order_status_num 5
              json.order_status '支付成功'
              json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'
            when 8
              #订单完成
              json.user_order_log_id log.ID
              json.order_status_num 8
              json.order_status '订单完成'
              json.record_time log.RecordTime ? log.RecordTime.strftime('%Y-%m-%d %H:%M:%S') : '无'

          end
        end
      end
    end
  end
end