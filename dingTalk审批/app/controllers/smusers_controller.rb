class SmusersController < ApplicationController
  before_action :is_login
  #Status字段 { 10 => '审核失败' ,20 => '审核中', 30 => '审核通过' }
  # 获取状态为20的业务员
  def get_smusers
    @is_menu = User.approval_permissions current_user.ID,'', '/SMUser/Index'
    if @is_menu[:is_allowed]
      @sm_users = SMUser.includes(:province, :city, :county).where({Status: 20}).order(CreateTime: :desc)
    end
  end

  def update_status
    status = params[:status]
    remark = params[:remark]
    user_type = params[:user_type]
    smuser_id = params[:smuser_id]
    user_type = 0 if user_type.nil?
    message = {}
    @sm_user = SMUser.where({ID: smuser_id}).first

    # 身份证和卡号一致性验证
    if status.to_i != 0
      url = URI.encode("#{Settings.verifybankcard}&realname=#{@sm_user.Name}&idcard=#{@sm_user.IDcardNo}&bankcard=#{@sm_user.BankCardNo}")
      response_v = HTTParty.get(url,:headers => {'Content-Type' => 'application/json'})
      response_v = JSON.parse(response_v.body)['result']

      if response_v.nil? || response_v['res'].to_i != 1
        update_smuser 10,user_type,remark,@sm_user,1
        render json: {status:'error',content: "身份证和卡号不一致!"} and return
      end
    end
    case status.to_i
      when 0
        # 审核驳回
        user_status = 10
        message_status = 1
      when 1
        # 通过审核
        user_status = 30
        message_status = 3
    end
    # old_status = @sm_user.Status
    ActiveRecord::Base.transaction do
      update_smuser user_status,user_type,remark,@sm_user,message_status
      # http://v.juhe.cn/verifybankcard3/query?key=c6de3050843f3e3be3eb486880cf2a48&realname=康建文&idcard=132123197104023614&bankcard=6210676802968333261
      if @sm
        message = {status: 'ok', content: "修改成功"}
      else
        message = {status: 'error', content: '修改失败'}
      end
    end


    render json: message
  end

  private

  # 审核业务员流程
  def update_smuser user_status,user_type,remark,sm_user,message_status
    @sm = @sm_user.update_attributes({Status: user_status, UserType: user_type})
    SMUserLog.create(SMUserID: sm_user.ID, SMUserStatus: user_status, Remark: remark,
                     CreateTime: Time.now, UpdateTime: Time.now, RealName: sm_user.Name,
                     IDCard: sm_user.IDcardNo, BankCard: sm_user.BankCardNo, Mobile: sm_user.Mobile)
    response = HTTParty.post(Settings.weixin.send_weixin_message,
                             :body => {:openid => sm_user.OpenID,
                                       :status => message_status

                             }.to_json,
                             :headers => {'Content-Type' => 'application/json'})
    return @sm
  end
end
