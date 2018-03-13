class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :is_login, except: [:home, :login]

  def home

  end


  def login
    # 用户登陆
    ding_talk_user_id = params[:ding_id]
    if ding_talk_user_id
      @user = User.where(ITCode: params[:it_code], Password: params[:password]).first
      if @user.nil?
        message = {status: 'error', content: '用户名或密码错误'}
      else
        remember_token = User.new_remember_token
        @user.update_attributes({DingTalkUserID: ding_talk_user_id, RememberToken: User.encrypt(remember_token)})
        message = {status: 'ok', remember_token: remember_token, name: @user.Name,
                   company_id: @user.CompanyID, department_id: @user.DepartmentID, content: '登录成功'}
      end
    else
      message = {status: 'error', content: '钉钉userID不能为空'}
    end

    render json: message
  end

  def show
    render json: current_user.Name
  end

end
