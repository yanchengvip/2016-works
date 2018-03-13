if @user_tasks_year_months.present?
  json.status 'ok'
  json.balance @balance.to_f
  json.data do
    json.array! @user_tasks_year_months.each do |year_month|
      json.year_month year_month
      json.month year_month.split('-')[1].to_i
      json.tasks do
        json.array! @user_tasks.each do |user_task|
          if user_task.BalanceEndTime.strftime('%Y-%m') == year_month
            json.id user_task.ID
            json.task_logo Settings.qiniu.qiniu_base_url + user_task.task.LogoQiNiu #任务logo
            json.task_name user_task.task.Title #任务名称
            json.current_step user_task.CurrentStep #当前级别
            json.current_reward user_task.CurrentReward #任务奖励金额
            json.return_amount  user_task.ReturnAmount #退货金额或者数量
            json.is_have_return user_task.IsHaveReturn #是否有退货,0=false,1=true
            json.return_award user_task.ReturnReward #退货或者取消而减少的奖励
            json.current_amount user_task.CurrentAmount #订单或者数量额度
            json.balance_end_time user_task.BalanceEndTime.strftime('%Y-%m-%d %H:%M')
            case user_task.task.Platform.to_i
              when 0
                json.task_platform_type 0 #任务来源平台
                json.task_platform '进货宝' #任务来源平台
            end
          end
        end
      end
    end
  end
else
  json.status 'error'
  json.data []
end
