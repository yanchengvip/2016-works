module Users
  module OrderHelper
    extend ActiveSupport::Concern


    # 从第三方平台获取订单信息
    def get_order_by_platform rand_num
      message = {status: 70, message: '网络不稳定,请稍后再试'}
      begin
        response = HTTParty.post(Settings.platform.jhb_bind_order,
                                 body: {RandomNum: rand_num}.to_json,
                                 headers: {'Content-Type' => 'application/json'})
        response = JSON.parse(response.body)
      rescue
        ErrorLog.create({Action: '根据识别码调用第三方提供的订单接口',Content: response,Remark: "RandomNum:#{rand_num}"})
        return {status: 60, message: '绑定失败!第三方提供的订单接口抛出异常！'}
      end

      case response['status']['Code'].to_i
        when 10
          #订单不存在
          ErrorLog.create({Action: '调用第三方提供的订单接口',Content: response['status']['Message'],Remark: "RandomNum:#{rand_num}"})
          message = {status: 10, message: response['status']['Message']}
        when 20
          ErrorLog.create({Action: '调用第三方提供的订单接口',Content: response['status']['Message'],Remark: "RandomNum:#{rand_num}"})
          message = {status: 20, message: '订单已发货,不能绑定!'}
        when 30
          response['data'].each_with_index { |order, index|
            order_id = order['OrderID']
            user_order = UserOrder.where(OrderID: order_id)
            if user_order.empty?
              #订单绑定
              if index > 0
                Thread.new {
                  sleep index
                  self.bind_order order
                }
              else
                result = self.bind_order order
                if result[:status].to_i == 1 #防止后台没有配置任务,友好提示
                  ErrorLog.create({Action: '绑定订单接口',Content: "该用户没有认领任务,后台可能没有配置任务.该用户UserID:#{self.ID}",Remark: "RandomNum:#{rand_num}"})
                  message = {status: 70, message: '网络不稳定,请稍后再试'}
                else
                  message = {status: 30, message: result[:message]}
                end
              end


            else
              ErrorLog.create({Action: '绑定订单接口',Content: response['status']['Message'],Remark: "RandomNum:#{rand_num}"})
              message = {status: 40, message: '订单已绑定，不能重复绑定!'}

            end
          }


        else
          ErrorLog.create({Action: '绑定订单接口',Content: "订单绑定失败!该用户UserID:#{self.ID}",Remark: "RandomNum:#{rand_num}"})
          message = {status: 50, message: '订单绑定失败!'}

      end
      return message
    end


    # 用户绑定订单
    def bind_order data
      order_city = data['BelongCityID']
      platform = data['From'].to_i
      user_task_order_arr = []
      user_task_arr = []
      user_task_log_arr = []
      # 获取订单对应进货宝平台任务的城市ID
      task_city = Task.task_city order_city, platform

      return {status: 'ok', message: '该订单所在城市没有关联进货团平台,关联后再重新绑定'} if !task_city[:status]

      current_user = self
      user_id = self.ID
      task_city_id = task_city[:task_city_id]
      option_params2 = {task_city_id: task_city_id}
      #当前用户有效期内的任务,并且任务所属城市对应第三方城市
      tasks = current_user.tasks.where('Status = ? and AllBelongCityID like ? and BeginTime <= ? and EndTime >= ?', 0, "%#{task_city_id},%", Time.now, Time.now)

      #user_order_logs中的OrderStatus来自订单，UserOrder中的OrderStatus值仅在取消和退货时保存，默认值为0
      user_order_atrr = {UserID: user_id, OrderID: data['OrderID'], OrderMoney: data['CostItem'], Platform: data['From'],
                         OrderCode: data['OrderCode'], ShipName: data['ShipName'], ShipTel: data['ShipTel'], OrderStatus: 0}
      user_order_log_atrr = {OrderID: data['OrderID'], OrderStatus: data['OrderStatus'], RecordTime: data['RecordTime'], Money: data['CostItem']}

      if !tasks.present?
        #如果用户所在城市没有任务,则不让绑定订单
        return {status: 1, message: '网络不稳定,请稍后再试'}
      end

      tasks.each do |task|
        # Type: 0=佣金比例基础(1%),1=订单达成金额,2=订单达成单数,3=订单达成单商品销量
        params = {
            task_id: task.ID,
            user_id: user_id,
            return_amount: 0
        }
        case task.Type.to_i
          when 0, 1
            # 佣金比例基础
            params = params.merge(amount: data['CostItem'].to_f)
            user_task_attrs, user_task_logs, option_params = UserTask.update_current_reward params
            user_task_order = {UserID: current_user.ID, TaskID: task.ID, OrderID: data['OrderID'],
                               Amount: data['CostItem'].to_f, ReturnAmount: 0, UserTaskID: option_params[:user_task_id]
            }
            user_task_order_arr.push(user_task_order)
            user_task_arr.push(user_task_attrs)
            user_task_log_arr.push(user_task_logs)

          when 2
            params = params.merge(amount: 1)
            user_task_attrs, user_task_logs, option_params = UserTask.update_current_reward params
            user_task_order = {UserID: current_user.ID, TaskID: task.ID, OrderID: data['OrderID'], Amount: 1, ReturnAmount: 0,
                               UserTaskID: option_params[:user_task_id]
            }
            user_task_order_arr.push(user_task_order)
            user_task_arr.push(user_task_attrs)
            user_task_log_arr.push(user_task_logs)
          when 3
            data['products'].each do |product|
              if product['ProductInfoID'] == task.task_product.ProductID
                params = params.merge(amount: product['Quantity'].to_i)
                user_task_attrs, user_task_logs, option_params = UserTask.update_current_reward params
                user_task_order = {UserID: current_user.ID, TaskID: task.ID, OrderID: data['OrderID'], Amount: product['Quantity'].to_i, ReturnAmount: 0,
                                   UserTaskID: option_params[:user_task_id]
                }
                user_task_order_arr.push(user_task_order)
                user_task_arr.push(user_task_attrs)
                user_task_log_arr.push(user_task_logs)
              end

            end
        end

      end

      order_save = Thread.new {
        self.bind_order_save user_order_atrr, user_task_order_arr, user_task_arr, user_order_log_atrr, user_task_log_arr, option_params2
      }
      order_save.join


      message = {status: 'ok', message: '绑定成功!'}

      return message
    end


    # 绑定订单保存
    def bind_order_save user_order_atrr, user_task_order_arr, user_task_arr, user_order_log_atrr, user_task_log_arr, option_params
      ActiveRecord::Base.transaction do
        user_task_order_arrs = []
        user_task_log_arrs = []
        user_task_arrs = []
        current_user = self
        task_city_id = option_params[:task_city_id]

        user_order = UserOrder.create(user_order_atrr)
        user_order.user_order_logs.create(user_order_log_atrr)


        # 推广员 手下用户订单金额的任务
        option_params2 = {task_city_id: task_city_id, type: 4}
        UserTask.extend_user_task current_user, user_order, option_params2

        # 推广员的佣金比例 手下用户订单金额之和*佣金比例
        option_params3 = {task_city_id: task_city_id, type: 5}
        UserTask.extend_user_task current_user, user_order, option_params3

        # 新增交易用户人数任务,首次绑定订单时有效
        user_order_num = current_user.user_orders.limit(2).count
        if user_order_num <= 1
          option_params1 = {type: 6}
          UserTask.extend_user_task current_user, user_order, option_params1
        end

        # 业务员自身任务
        user_task_arr.each do |user_task_atrr|
          user_task_arrs << UserTask.new(user_task_atrr)
        end

        UserTask.import user_task_arrs, on_duplicate_key_update: [:CurrentAmount, :CurrentStep, :CurrentReward, :ReturnAmount]

        user_task_order_arr.each do |user_task_order_atrr|
          user_task_order_atrrs = user_task_order_atrr.merge({UserOrderID: user_order.ID})

          user_task_order_arrs << UserTaskOrder.new(user_task_order_atrrs)
        end
        user_task_order_arrs.each do |user_task_order_atrr|
          user_task_order_atrr.run_callbacks(:create) { false }
        end
        UserTaskOrder.import user_task_order_arrs

        user_task_log_arr.each do |user_task_log_atrr|

          user_task_log_arrs << UserTaskLog.new(user_task_log_atrr)
        end
        user_task_log_arrs.each do |user_task_log_atrr|
          user_task_log_atrr.run_callbacks(:create) { false }
        end
        UserTaskLog.import user_task_log_arrs

        # 向进货宝同步绑定订单的用户
        User.smuser_order_to_jhb user_order.UserID, user_order.user.Name, user_order.user.Mobile, user_order.OrderID

      end

    end

    # 绑定订单保存后，向进货宝同步用户信息
    def User.smuser_order_to_jhb user_id, user_name, mobile, order_id
      begin

        response = HTTParty.post(Settings.platform.jhb_insert_smuser,
                                 body: {UserID: user_id, OrderID: order_id, UserName: user_name, UserMobile: mobile}.to_json,
                                 headers: {'Content-Type' => 'application/json'})
        response = JSON.parse(response.body)

      rescue
        p response
        p 'GetOrderDetails/Insert!第三方提供的订单接口抛出异常！'
        ErrorLog.create({Action: '第三方提供的订单接口:绑定订单保存后，向进货宝同步用户信息',Content: response,Remark: "user_id:#{user_id};order_id:#{order_id}"})
        return {status: 60, message: 'GetOrderDetails/Insert!第三方提供的订单接口抛出异常！', response: response}
      end
    end


    # 仅供内部管理员使用!请勿对外开发此接口!!!!
    # 从第三方平台获取订单信息,没有任何验证，仅供内部管理员手动绑订单使用
    def get_order_by_admin order_id

      begin
        response = HTTParty.post(Settings.platform.jhb_bind_order_by_admin,
                                 body: {RandomNum: order_id}.to_json,
                                 headers: {'Content-Type' => 'application/json'})
        response = JSON.parse(response.body)
      rescue
        return {status: 60, message: '绑定失败!第三方提供的订单接口抛出异常！'}
      end

      case response['status']['Code'].to_i
        when 10
          #订单不存在
          message = {status: 10, message: response['status']['Message']}
        when 20
          message = {status: 20, message: '订单已发货,不能绑定!'}
        when 30
          order_id = response['data']['OrderID']

          user_order = UserOrder.where(OrderID: order_id)
          if user_order.empty?

            result = self.bind_order response['data']

            message = {status: 30, message: result[:message]}
          else
            message = {status: 40, message: '订单已绑定，不能重复绑定!'}

          end


        else
          message = {status: 50, message: '订单绑定失败!'}

      end
      return message
    end
  end
end
