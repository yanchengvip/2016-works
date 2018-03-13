class UsersController < ApplicationController
  before_action :is_login, except: [:user_info,:bind_order_by_admin]


  # 业务员绑定订单
  def bind_order
    rand_num = params[:rand_num]
    message = current_user.get_order_by_platform rand_num
    render json: message
  end



  # 用户收入
  def user_incoming
    @user = current_user
    # 已结算并且完成的任务的总收入
    @balanced = UserTask.where('UserID = ? and CurrentStep >= ? and BalanceEndTime < ?', current_user.ID, 1, Time.now).sum('CurrentReward')
    # 全部达标，但未结算的任务总收入
    @no_balanced = UserTask.where('UserID = ? and CurrentStep >= ? and BalanceEndTime >= ?', current_user.ID, 1, Time.now).sum('CurrentReward')

    # 用户的临时二维码地址
    @url = current_user.create_qrcode
    @user_logo = $weixin.user(current_user.OpenID).result['headimgurl']
  end

  # 用户已结算的收入明细
  def user_balanced
    page = params[:page] ||= 1
    per_page = params[:per_page] ||= 50
    # 已结算并且完成的任务的总收入
    @balance = UserTask.where('UserID = ? and CurrentStep >= ? and BalanceEndTime < ?', current_user.ID, 1, Time.now).sum('CurrentReward')

    # 已结算的任务
    @user_tasks = current_user.user_tasks.includes(:task).where('user_tasks.BalanceEndTime < ?', Time.now).order('user_tasks.BalanceEndTime desc')
                      .paginate(page: page, per_page: per_page)
    # 已结算中包含的月份
    #@user_tasks_year_months = @user_tasks.pluck("distinct DATE_FORMAT(user_tasks.BalanceEndTime,'%Y-%m')")
    @user_tasks_year_months = @user_tasks.pluck("DATE_FORMAT(user_tasks.BalanceEndTime,'%Y-%m')").uniq

    render 'users/user_balance'
  end

  # 用户未结算收入明细
  def user_not_balanced
    page = params[:page] ||= 1
    per_page = params[:per_page] ||= 50
    # 全部达标，但未结算的任务总收入
    @balance = UserTask.where('UserID = ? and CurrentStep >= ? and BalanceEndTime >= ?', current_user.ID, 1, Time.now).sum('CurrentReward')
    # 未结算的任务
    @user_tasks = current_user.user_tasks.includes(:task).where('user_tasks.BalanceEndTime >= ?', Time.now).order('user_tasks.BalanceEndTime desc')
                      .paginate(page: page, per_page: per_page)

    # 未结算中包含的月份
    #@user_tasks_year_months = @user_tasks.pluck("distinct DATE_FORMAT(user_tasks.BalanceEndTime,'%Y-%m')")
    @user_tasks_year_months = @user_tasks.pluck("DATE_FORMAT(user_tasks.BalanceEndTime,'%Y-%m')").uniq

    render 'users/user_balance'
  end

  # 用户当前地址
  def user_address
    @city = City.includes(:province).where(ID: current_user.CityID).first
    @county = County.where(ID: current_user.CountyID).first
    render json: {provinceID: @city.province.ID, provinceName: @city.province.ProvinceName, cityID: @city.ID, cityName: @city.CityName,
                  countyID: @county.present? ? @county.ID : '', countyName: @county.present? ? @county.CountyName : ''}
  end

  # 用户个人信息
  def user_info
    # 可能为审核失败的用户
    message = {status: 'error', message: 'remember_token为空'}
    @sm_user = User.where({RememberToken: User.encrypt(params[:remember_token])}).first
    if !@sm_user.nil?
      message = {status: 'ok', name: @sm_user.Name, IDcardNo: @sm_user.IDcardNo, bankCardNo: @sm_user.BankCardNo,
                 mobile: @sm_user.Mobile, IDcardPic: @sm_user.IDcardPic, BandCardPic: @sm_user.BandCardPic,
                 BankAccount: @sm_user.BankAccount, BankProvince: @sm_user.BankProvince, BankCity: @sm_user.BankCity, BankBranch: @sm_user.BankBranch}

    end


    render json: message
  end


  # 修改用户地址
  def update_address
    provinceID = params[:ProvinceID]
    cityID = params[:CityID]
    countyID = params[:CountyID]
    if countyID == ''
      flag = current_user.update_attributes(user_city.merge({CountyID: nil}))
    else
      flag = current_user.update_attributes(user_city)
    end

    if flag
      message = {status: 'ok', message: '修改成功'}
    else
      message = {status: 'error', message: '修改失败'}
    end

    render json: message

  end


  # 管理员手动给指定的业务员绑定订单，为了防止业务员绑定失败，谨慎对外开放
  def bind_order_by_admin
    order_id = params[:order_id]  #订单ID
    user_id = params[:user_id]
    current_user = User.find(user_id)
    if current_user
      message = current_user.get_order_by_admin order_id
    else
      message = {status: 'error',message: 'user_id不存在'}
    end

    render json: message
  end


  private

  def user_params
    params.require(:user).permit(:ID, :Mobile, :ProvinceID, :CityID, :CountyID, :Name, :IDcardNo, :BankCardNo, :IDcardPic, :BandCardPic, :Status,
                                 :BankBranch, :BankAccount, :BankProvince, :BankCity, :RememberToken, :OpenID, :UserType, :IsDisabled)
  end

  def user_city
    params.permit(:ProvinceID,:CityID,:CountyID)
  end

end
