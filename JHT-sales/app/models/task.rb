# 推广员任务：
# 1、推广用户订单金额任务——推广员 手下用户订单金额之和 达成任务（任务的起始时间若与业务员任务的起始时间不一致会有问题，暂时后台手动控制时间与业务员任务的起始时间一致）
# 2、推广用户订单佣金任务——推广员 手下用户订单佣金之和 佣金比例（任务的起始时间若与业务员任务的起始时间不一致会有问题，暂时后台手动控制时间与业务员任务的起始时间一致）
# 3、新增交易用户人数任务——推广员 手下新增交易用户数   该推广员手下用户首次绑定订单且绑定时间在本任务周期内

# ReceiveType: 0= 自动接受,1 = 用户手动接受
# SubmitType: 0 = 用户手动录入识别码绑定，1 = 用户拍照上传资料
# CheckType : 0 = 系统自动，1 = 人工审核

# Status: 0=正常可用，1="假删除"
# Type: 0=佣金比例基础(1%),1=订单达成金额,2=订单达成单数,3=订单达成单商品销量,4=新增交易用户人数任务,5=推广用户订单金额任务,6=推广用户订单佣金任务
class Task < ActiveRecord::Base
  self.table_name = 'tasks'
  include UUIDHelper
  has_many :task_steps, -> { order('Step asc') }, foreign_key: 'TaskID'
  has_one :task_product, foreign_key: 'TaskID'
  has_many :user_tasks, foreign_key: 'TaskID'
  has_many :user_task_orders,foreign_key: 'TaskID'



  # 判断第三方订单城市的ID对应进货团任务task的cityID
  def self.task_city order_city,platform
    status = false
    # 获取订单order关联任务task的城市
    platform_city = PlatformCity.where(Platform: platform, OtherPlatformCityID: order_city).first
    if platform_city.present?
      task_city_id = platform_city.CityID
      status = true
    end
    data = {status: status, task_city_id: task_city_id}
    return data
  end

  # 为用户自动分配任务
  def self.assign_new_tasks current_user
    # 获取目前全部有效任务的id
    if current_user.UserType == 0
      task_ids = Task.where('TaskObject in (0,1) and BeginTime <= ? and EndTime >= ? and Status = ? and ReceiveType = ? and AllBelongCityID like ? ',Time.now,Time.now,0,0,"%#{current_user.CityID},%").pluck(:ID)
    end
    if current_user.UserType == 1
      task_ids = Task.where('TaskObject in (0,2) and BeginTime <= ? and EndTime >= ? and Status = ? and ReceiveType = ? and AllBelongCityID like ? ',Time.now,Time.now,0,0,"%#{current_user.CityID},%").pluck(:ID)
    end

    # 获取当前用户已领取有效任务的全部id
    current_user_task_ids = current_user.user_tasks.joins(:task)
                                .where('tasks.Status = ? and tasks.BeginTime <= ? and tasks.EndTime >= ? ',0,Time.now,Time.now)
                                .pluck(:TaskID)
    #当前用户未领取的有效新任务
    new_task_ids = task_ids - current_user_task_ids

    return {status: 0,message: '没有可分配的新任务'} if new_task_ids.empty?

    tasks_arr = Task.where(ID: new_task_ids).pluck(:ID,:BalanceEndTime,:TaskObject) #[["035f19e2-e2f6-4419-a402-22cde39e2b89", Fri, 02 Sep 2016 23:59:59 CST +08:00], ["0979dcce-0720-403a-8ba0-17e7e0ea919a", Sun, 04 Sep 2016 23:59:59 CST +08:00]]
    users_tasks_arr = []
    tasks_arr.each do |task|
      users_tasks_arr.push({TaskID: task[0],BalanceEndTime: task[1],TaskObject: task[2]})
    end
    response = current_user.user_tasks.create(users_tasks_arr)
    if response.empty?
      message = {status: 0,message: '没有可分配的新任务'}
    else
      message = {status: 1,message: '新任务分配成功'}
    end

    return message
  end







end
