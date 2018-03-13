class TaskStep < ActiveRecord::Base
  self.table_name = 'task_step'
  include UUIDHelper
  belongs_to :task, foreign_key: 'TaskID'

  # 目前达到的级别
  def self.get_step_by_amount task_id, amount, task_type
    if [0, 5].include? task_type.to_i
      #基础佣金任务，基础佣金任务时仅有一个任务阶段
      @task_step = TaskStep.where('TaskID = ? ', task_id).order('Amount desc').first
    else
      #其他任务
      @task_step = TaskStep.where('TaskID = ? and Amount <= ?', task_id, amount).order('Amount desc').first
    end


    return @task_step
  end
end