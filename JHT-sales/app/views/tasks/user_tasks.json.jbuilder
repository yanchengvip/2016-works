json.status 'ok'
json.data do
  json.array! @user_tasks.each do |user_task|
    task = user_task.task
    json.title task.Title
    json.description task.Description #任务规则介绍
    json.user_task_id user_task.ID
    json.task_logo Settings.qiniu.qiniu_base_url + task.LogoQiNiu.to_s
    json.current_reward user_task.CurrentReward.to_f #当前奖励
    json.current_amount user_task.CurrentAmount
    json.return_amount  user_task.ReturnAmount #退货金额或者数量
    json.is_have_return user_task.IsHaveReturn #是否有退货,0=false,1=true
    json.return_award user_task.ReturnReward #退货或者取消而减少的奖励
    json.current_step user_task.CurrentStep #当前级别
    json.task_id task.ID
    json.title task.Title
    json.belong_city task.AllBelongCity.split(',')[0]
    json.begin_time task.BeginTime.strftime('%Y-%m-%d %H:%M') #任务开始时间
    json.end_time task.EndTime.strftime('%Y-%m-%d %H:%M')  #任务结束时间
    json.balance_end_time task.BalanceEndTime ? task.BalanceEndTime.strftime('%Y-%m-%d %H:%M') : ''#任务结算时间
    json.type task.Type.to_i  #0=佣金比例基础任务,1=目标额度,2=订单数量
    json.orders_num user_task.user_orders.length#任务关联的订单数量
    json.users_num user_task.user_orders.select(:UserID).distinct.count #任务中关联订单的人数
    # 剩余时间
    if (DateTime.parse(task.EndTime.strftime('%Y-%m-%d')) - DateTime.parse(Time.new.strftime('%Y-%m-%d'))).to_i == 0
      json.end_days ((DateTime.parse(task.EndTime.strftime('%Y-%m-%d %H')) - DateTime.parse(Time.new.strftime('%Y-%m-%d %H'))) * 24).to_i.to_s + '小时'
    else
      json.end_days ((DateTime.parse(task.EndTime.strftime('%Y-%m-%d')) - DateTime.parse(Time.new.strftime('%Y-%m-%d'))).to_i + 1).to_s + '天'
    end

    # 任务状态
    if Time.now < task.BeginTime
      json.is_start 1 #任务未开始
    elsif task.BeginTime <= Time.now && Time.now < task.EndTime
      json.is_start 3 #任务进行中
    elsif Time.now >= task.EndTime && user_task.CurrentStep == 0
      json.is_start 2 #任务已结束,并且未完成任务
    elsif Time.now >= task.EndTime && Time.now <= task.BalanceEndTime && user_task.CurrentStep > 0
      json.is_start 4 #任务待结算，已完成
    elsif Time.now > task.BalanceEndTime && user_task.CurrentStep > 0
      json.is_start 5 #任务已结算
    end

    # 任务结算状态
    if Time.now < task.BalanceEndTime
      json.is_balanced 1 #任务未结算
    else
      json.is_balanced 2 #任务已结算
    end

    # 任务的阶段终极目标
    case task.Type.to_i
      when 0
        json.work_target task.task_steps.empty? ? '1%' : task.task_steps.last.Amount #佣金比例基础任务
      when 1,2
        json.work_target task.task_steps.empty? ? '无' : task.task_steps.last.Amount
      when 3
        json.work_target task.task_product.present? ? task.task_product.ProductName : '' #目标商品

      else
        json.work_target '无目标...'
    end
    json.task_steps do
      json.array! task.task_steps do |task_step|
        json.step task_step.Step
        json.amount task_step.Amount #目标数量
        json.reward task_step.Reward #任务奖励
      end
    end

  end
end