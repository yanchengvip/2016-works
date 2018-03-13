class TasksController < ApplicationController
  before_action :is_login
  #全部任务
  def list
    page = params[:page] ||= 1
    per_page = params[:per_page] ||= 30
    conditions = ['Status = ?','AllBelongCityID like ?']
    values = [0,"%#{current_user.CityID},%"]

    case current_user.UserType
      when 0
        #普通业务员
        conditions << 'TaskObject in (0,1)'
      when 1
        #推广业务员
        conditions << 'TaskObject in (0,2)'
    end
    # 只显示用户所在城市和TaskObject符合用户类型 的任务

    @tasks = Task.includes(:task_product, :task_steps).where(conditions.join(' and '), *values)
                 .order(EndTime: :asc).paginate(page: page, per_page: per_page)
  end


  # 单个任务详情
  def task_details
    @task = Task.includes(:task_product, :task_steps).where(ID: params[:task_id]).first
  end

  # 用户领取的全部任务
  def user_tasks
    page = params[:page] ||= 1
    per_page = params[:per_page] ||= 15
    status = params[:status].to_i
    conditions = ['UserID = ? ']
    values = ["#{current_user.ID}"]
    if status == 1
      # 查询用户已结算的任务,包括达标和未达标的任务
      conditions << 'user_tasks.BalanceEndTime <= ? '
      values << Time.now
    end

    if status == 2
      # 查询用户已结算并且达标的任务
      conditions << 'user_tasks.BalanceEndTime <= ?  and CurrentStep >= ? '
      values << Time.now
      values << 1
    end

    if status == 3
      # 查询用户未结算并且达标的任务
      conditions << 'user_tasks.BalanceEndTime >= ?  and CurrentStep >= ? '
      values << Time.now
      values << 1
    end

    if status == 4
      # 查询用户进行中的任务
      # task_ids = Task.where('BeginTime <= ? and EndTime >= ?',Time.now,Time.now).pluck(:ID)
      # conditions << "TaskID in (?) "
      # values << task_ids
      conditions << 'tasks.BeginTime <= ? and tasks.EndTime >= ?'
      values << Time.now
      values << Time.now

    end

    if status == 5
      # 查询用户结束的任务
      # task_ids = Task.where('EndTime < ?',Time.now).pluck(:ID)
      # conditions << "TaskID in (?) "
      # values << task_ids
      conditions << 'tasks.EndTime < ?'
      values << Time.now

    end
    @user_tasks = UserTask.joins(:task).includes(:task_steps,:task_product,:user_orders)
                      .where(conditions.join(' and '), *values)
                      .paginate(page: page, per_page: per_page).order('tasks.Sort asc,tasks.BalanceEndTime asc')

  end


  # 用户的单个任务详情
  def user_task_details
    user_task_id = params[:user_task_id]
    @user_task = UserTask.includes(:task,:task_steps,:user_task_orders,:user_orders).where(ID: user_task_id).first
    @current_task_step = TaskStep.where(TaskID: @user_task.TaskID,Step: @user_task.CurrentStep).first
  end

  # 领取任务
  def get_task
    task_id = params[:task_id]
    # Status: 0=正常可用，1="假删除"
    task = Task.where(ID: task_id,Status: 0).first

    render json: {status: 0, message: '该任务已取消'} and return if task.nil?

    user_task = UserTask.where(UserID: current_user.ID, TaskID: task.ID)
    if user_task.empty?
      flag = UserTask.create(UserID: current_user.ID, TaskID: task.ID, CurrentAmount: 0, CurrentStep: 0, ReturnAmount: 0,
                             BalanceEndTime: task.BalanceEndTime, TaskObject: task.TaskObject)
      if flag
        message = {status: 1, message: '领取成功!'}
      else
        message = {status: 0, message: '领取失败!'}
      end
    else
      message = {status: 0, message: '用户已领取该任务!'}
    end
    render json: message
  end


  #为用户自动分配新任务
  def assign_new_tasks
    message = Task.assign_new_tasks current_user
    render json: message
  end

end
