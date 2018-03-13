class RegisterController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    # 微信code
    code = params[:code]
    redirect_to URI.encode(Settings.weixin.jhtwebchat+"?code=#{code}&status=4&message=用户未注册")
  end

  # 注册创建用户
  def create
    code = params[:code]
    check_code = params[:check_code]
    mobile = params[:Mobile]
    county_id = params[:CountyID]
    if $cache.read("#{mobile}_check_code") == check_code
      openid = User.get_openid code
      # 防止注册时第二次提交code失效，获取不到openid,每个code只能使用一次
      $cache.write("#{code}_weixin", openid, :expire_in => 10.minutes) if !openid.nil?
      openid ||= $cache.read("#{code}_weixin")
      @user = User.new(user_params.merge({OpenID: openid,Status: 10}))
      if county_id.to_i == 0
        @user = User.new(user_params.merge({OpenID: openid,CountyID: nil,Status: 10}))
      else
        @user = User.new(user_params.merge({OpenID: openid,Status: 10}))
      end
      # p @user.errors.full_messages
      # modle验证失败回调
      render json: {status: 'error', message: @user.errors.first[1]} and return if !@user.valid?
      if @user.save!
        remember_token = User.new_remember_token
        sign_in @user, remember_token
        $weixin.send_text_custom(@user.OpenID, '注册成功,请完善信息认证!')
        @user.guanzhu_user_by_openid
        @message ={status: 'ok', message: '注册成功', remember_token: remember_token}

      else
        @message ={status: 'error', message: '注册失败', result: @user.errors}
      end
    else

      @message ={status: 'error', message: '验证码错误'}
    end

    render json: @message
  end

  # 用户认证
  def user_verify
    remember_token = params[:remember_token]
    #mobile = params[:Mobile]
    current_user = User.find_by({RememberToken: User.encrypt(remember_token), Status: [10, 20]})

    ActiveRecord::Base.transaction do
      @message = {status: 'error', message: "保存失败!"}
      current_user.update_attributes(user_verify_params)
      card_url = User.qiniu_fetch current_user.IDcardPic
      bank_url = User.qiniu_fetch current_user.BandCardPic
      current_user.update_attributes({IDcardPic: card_url, BandCardPic: bank_url})
      # 身份证和卡号一致性验证
      response_v = User.verify_card_bank current_user.Name, current_user.IDcardNo, current_user.BankCardNo
      if response_v.nil? || response_v['res'].to_i != 1
        current_user.update_attributes({Status: 20})
        UserLog.create(UserID: current_user.ID, UserStatus: 20, Remark: '认证失败，身份证和卡号不一致!',
                       CreateTime: Time.now, UpdateTime: Time.now, RealName: current_user.Name,
                       IDCard: current_user.IDcardNo, BankCard: current_user.BankCardNo, Mobile: current_user.Mobile)
        options = {
            openid: current_user.OpenID,
            status: 1,
            content: "认证失败,身份证和卡号不一致!"
        }
        WeixinMenu.send_template_message options
        @message = {status: 'error', message: "认证失败,身份证和卡号不一致!"}
      else
        current_user.update_attributes({Status: 30, AuditedTime: Time.now})
        UserLog.create(UserID: current_user.ID, UserStatus: 30, Remark: '认证成功!',
                       CreateTime: Time.now, UpdateTime: Time.now, RealName: current_user.Name,
                       IDCard: current_user.IDcardNo, BankCard: current_user.BankCardNo, Mobile: current_user.Mobile)
        options = {
            openid: current_user.OpenID,
            status: 2,
            content: "恭喜您,审核成功"
        }
        WeixinMenu.send_template_message options
        @message ={status: 'ok', message: '认证成功'}

      end
    end
    render json: @message
  end


  # 获取验证码
  def send_check_code
    mobile = params[:mobile]
    @user = User.where(mobile: mobile)
    if @user.empty?
      result = Sms.send_check_code mobile
      # result返回值['000000',null]代表发送成功，["160038","短信验证码发送过频繁"]失败，等等
      if result.first == '000000'
        render json: {status: 'ok', message: '发送成功'}
      else
        render json: {status: 'error', message: result.second}
      end


    else
      render json: {status: 'error', message: '此手机号已被注册!'}
    end


  end

  # 验证码是否正确或者有效
  def valid_check_code
    mobile = params[:mobile]
    check_code_input = params[:check_code]
    check_code_cache = $cache.read("#{mobile}_check_code")
    if !check_code_input.nil? && check_code_input == check_code_cache && check_code_input != ''
      render json: {status: 'ok', message: '验证码正确'}
    else
      render json: {status: 'error', message: '验证码无效'}
    end
  end


  # 验证手机号
  def valid_mobile
    mobile = params[:mobile]
    if (mobile =~/^1[3|4|5|7|8]\d{9}$/)
      @user = User.find_by(mobile: mobile)
      if @user.nil?
        @message = {status: 'ok', message: '手机号没有注册过，可以使用'}
      else
        @message = {status: 'error', message: '此手机号已被注册!'}
      end
    else
      @message = {status: 'error', message: '手机号格式不正确'}
    end
    render json: @message
  end


  private

  def user_params
    # params.require(:user).permit(:Name, :IDcardNo, :BankCardNo, :IDcardPic, :BandCardPic, :BankBranch, :BankAccount, :BankProvince, :BankCity)
    params.permit(:Mobile, :ProvinceID, :CityID, :CountyID)

  end

  def user_verify_params
    params.permit(:Name, :IDcardNo, :BankCardNo, :IDcardPic, :BandCardPic, :BankBranch, :BankAccount, :BankProvince, :BankCity)
  end

end

