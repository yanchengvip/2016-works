class UserTask < ActiveRecord::Base
  self.table_name = 'user_tasks'
  belongs_to :task, foreign_key: 'TaskID'
  belongs_to :user, foreign_key: 'UserID'
  has_one :task_product, through: :task, foreign_key: 'TaskID'
  has_many :user_task_orders,->{order('CreateTime desc')}, foreign_key: 'UserTaskID'
  has_many :task_steps, through: :task, foreign_key: 'TaskID'
  has_many :user_orders, through: :user_task_orders, foreign_key: 'UserTaskID'
  has_many :user_task_logs, foreign_key: 'UserTaskID'
  include UUIDHelper
  after_save :update_time


  # 修改任务的当前达成数额,amount和return_amount的值根据任务状态不同而变化，有可能为订单数量或者产品数量，或者订单金额
  def self.update_current_reward params
    task_id = params[:task_id]
    user_id = params[:user_id]
    amount = params[:amount]
    order_status = params[:order_status]
    return_amount = params[:return_amount]
    @user_task = UserTask.includes(:task).where(TaskID: task_id, UserID: user_id).first
    user_task_id = @user_task.ID
    option_params = {user_task_id: user_task_id}
    current_amount = @user_task.CurrentAmount.to_f + amount.to_f #根据任务不同显示，可能为任务的商品数量或者订单总金额
    return_amount = @user_task.ReturnAmount.to_f + return_amount.to_f #任务的退货数量或者金额
    cancel_amount = @user_task.CancelAmount.to_f + return_amount.to_f #任务的取消数量或者金额
    # 根据用户当前的amount，获取任务的级别
    @task_step = TaskStep.get_step_by_amount task_id, current_amount, @user_task.task.Type

    # 当前佣金
    if @user_task.task.Type == 0 || @user_task.task.Type == 5
      # 基础佣金时，累加 CurrentAmount(CurrentAmount为订单总金额的值)和CurrentReward
      reward = @task_step ? @task_step.Reward : 0
      current_reward = @user_task.CurrentReward.to_f + amount.to_f * reward.to_f #佣金奖励
      option_params = option_params.merge(single_order_commission: amount.to_f * reward.to_f) #返回单笔订单的佣金
    else
      #其他任务
      current_reward = @task_step ? @task_step.Reward : 0
    end

    current_step = @task_step ? @task_step.Step : 0
    user_task_attrs = {CurrentAmount: current_amount, CurrentStep: current_step,
                       CurrentReward: current_reward, ReturnAmount: return_amount, ID: @user_task.ID}

    # 计算订单退货或者取消时，奖励减少的钱
    return_reward = @user_task.ReturnReward.to_f
    if amount.to_f < 0
      #奖励减少的钱
      reduce_reward = @user_task.CurrentReward.to_f - current_reward
      # 此任务奖励一共减少的钱
      return_reward += reduce_reward

      if current_amount <= 0
        user_task_attrs = user_task_attrs.merge({CurrentStep: 0})
      end
      if order_status == -1
        # 订单取消
        user_task_attrs.delete(:ReturnAmount)
        user_task_attrs = user_task_attrs.merge({CancelAmount:cancel_amount,CancelReward: return_reward,IsHaveCancel:true}) #记录任务是否有取消的订单
      end
      if order_status == -2
        # 订单退货
        user_task_attrs = user_task_attrs.merge({IsHaveReturn: true, ReturnReward: return_reward}) #记录任务是否有退货的订单
      end

      if order_status == -3
        # 分单取消(一个订单分为多个子订单,母订单取消)
        user_task_attrs.delete(:ReturnAmount)
      end

    end
    user_task_logs = {UserID: @user_task.UserID, TaskID: @user_task.TaskID, CurrentAmount: @user_task.CurrentAmount, CurrentStep: @user_task.CurrentStep,
                      CurrentReward: @user_task.CurrentReward, ReturnAmount: @user_task.ReturnAmount, BalanceEndTime: @user_task.BalanceEndTime}

    return user_task_attrs, user_task_logs, option_params
  end


  #推广员任务
  def self.extend_user_task normal_user, user_order, option_params
    # option_params = {task_city_id:xx,single_order_commission:xx,type:xx}
    task_city_id = option_params[:task_city_id]
    type = option_params[:type]
    # 查询关联的推广员
    user_relation = normal_user.user_relation
    return {status: 'error', message: '没有关联推广员'} if user_relation.nil?
    extend_user = user_relation.user #推广员
    params = {
        task_city_id: task_city_id,
        type: type,
        extend_user: extend_user,
        normal_user: normal_user,
        user_order: user_order
    }
    case type.to_i
      when 4,5
        #4.推广员 手下用户订单金额的任务
        #5.推广员 手下用户订单佣金任务
        params = params.merge(amount: user_order.OrderMoney.to_f)
      when 6
        #推广员 新增用户任务
        params = params.merge(amount: 1) #1为1个人
    end

    extend_user_task_money_save params
  end


  private

  def update_time
    self.UpdateTime = Time.now
  end


  #推广员 1.手下用户订单金额的任务 2.订单之和的佣金任务 3.新增用户任务
  def self.extend_user_task_money_save params
    extend_user = params[:extend_user]
    normal_user = params[:normal_user]
    user_order = params[:user_order]
    task_city_id = params[:task_city_id]
    amount = params[:amount]
    type = params[:type]
    return if !extend_user.present?
    extend_user_id = extend_user.ID
    if type == 6
      # 当前用户第一次绑定订单时，为他的推广业务员计算新增用户任务的佣金
      tasks = extend_user.tasks.includes(:task_steps).where('Status = ? and Type = ? and BeginTime <= ? and EndTime >= ?', 0, type, Time.now, Time.now)
    else
      tasks = extend_user.tasks.includes(:task_steps).where('Status = ? and Type = ? and AllBelongCityID like ? and BeginTime <= ? and EndTime >= ?', 0, type, "%#{task_city_id},%", Time.now, Time.now)
    end
    tasks.each do |task|
      params = {
          task_id: task.ID,
          user_id: extend_user_id,
          amount: amount,
          return_amount: 0
      }
      user_task_attrs, user_task_logs, option_params = UserTask.update_current_reward params
      user_task_order = {UserID: extend_user_id, TaskID: task.ID, OrderID: user_order.OrderID, Amount: amount, ReturnAmount: 0,
                         UserTaskID: option_params[:user_task_id], NormalUserID: normal_user.ID, UserOrderID: user_order.ID
      }
      UserTask.import [UserTask.new(user_task_attrs)], on_duplicate_key_update: [:CurrentAmount, :CurrentStep, :CurrentReward, :ReturnAmount]
      UserTaskOrder.create(user_task_order)
      UserTaskLog.create(user_task_logs)
    end
  end

end
