if @user_task.nil?
  json.status 'error'
  json.data []
else
  return_orders = []
  json.status 'ok'
  json.data do
    json.title @user_task.task.Title #任务名称
    json.description @user_task.task.Description #任务规则介绍
    json.user_task_id @user_task.ID
    json.task_type @user_task.task.Type #0=佣金比例基础任务,1=目标额度,2=订单数量
    json.belong_city @user_task.task.AllBelongCity.split(',')[0]
    json.task_logo Settings.qiniu.qiniu_base_url + @user_task.task.LogoQiNiu.to_s
    json.begin_time @user_task.task.BeginTime.strftime('%Y-%m-%d %H:%M') #任务开始时间
    json.end_time @user_task.task.EndTime.strftime('%Y-%m-%d %H:%M') #任务结束时间
    json.balance_end_time @user_task.task.BalanceEndTime ? @user_task.task.BalanceEndTime.strftime('%Y-%m-%d %H:%M') : '' #任务结算时间
    json.current_reward @user_task.CurrentReward #当前奖励金额
    json.return_amount @user_task.ReturnAmount #退货金额或者数量
    json.is_have_return @user_task.IsHaveReturn #是否有退货,0=false,1=true
    json.return_award @user_task.ReturnReward #退货或者取消而减少的奖励
    json.current_step @user_task.CurrentStep #当前级别
    json.CurrentAmount @user_task.CurrentAmount #销售额,也可能为订单数量  --根据任务类型区别

    # 任务状态
    if Time.now < @user_task.task.BeginTime
      json.is_start 1 #任务未开始
    elsif @user_task.task.BeginTime <= Time.now && Time.now < @user_task.task.EndTime
      json.is_start 3 #任务进行中
    elsif Time.now >= @user_task.task.EndTime && @user_task.CurrentStep == 0
        json.is_start 2 #任务已结束,并且未完成任务
    elsif Time.now >= @user_task.task.EndTime && Time.now <= @user_task.task.BalanceEndTime && @user_task.CurrentStep > 0
      json.is_start 4 #任务待结算,并且完成任务
    elsif Time.now > @user_task.task.BalanceEndTime && @user_task.CurrentStep > 0
      json.is_start 5 #任务已结算，并且完成任务
    end

    # 任务结算状态
    if Time.now < @user_task.task.BalanceEndTime
      json.is_balanced 1 #任务未结算
    else
      json.is_balanced 2 #任务已结算
    end

    # 任务阶段
    json.task_steps do
      json.array! @user_task.task.task_steps.each do |step|
        json.task_step_id step.ID
        json.step step.Step #级别
        json.amount step.Amount #目标数量
        json.reward step.Reward #任务奖励
      end
    end

    # 任务中的订单
    json.orders do
      json.array! @user_task.user_task_orders.each do |uto|
        if uto.user_order.IsHaveReturn
          #说明有退货
          return_orders.push(uto)
        end
        json.user_order_id uto.user_order.ID
        json.order_code uto.user_order.OrderCode
        json.order_money uto.user_order.OrderMoney
        json.is_have_return uto.user_order.IsHaveReturn
        json.return_money uto.user_order.ReturnMoney
        json.normal_user uto.user_order.user.Name #绑定订单的业务员，当为推广业务员任务时，显示的是手下普通业务员的名字
        json.bind_order_time uto.user_order.CreateTime.strftime('%Y-%m-%d') #绑定订单的时间
        json.amount uto.Amount #佣金或者是订单金额或者是订单数量等，根据任务类型不同
      end
    end

    # 退货订单详情
    json.return_amount @user_task.ReturnAmount
    json.return_orders do
      json.array! return_orders.each do |user_task_order|
        json.user_order_id user_task_order.user_order.ID
        json.order_code user_task_order.user_order.OrderCode
        json.return_amount user_task_order.ReturnAmount
      end
    end
  end
end

