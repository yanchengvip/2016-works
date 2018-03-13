class DingsController < ApplicationController
  # 获取钉钉签名
  def ding_signature
    url = params[:url]
    # url = 'http://yc.tunnel.jinhuobao.com.cn/users'
    @client = Client.new
    access_token = @client.get_access_token
    jsapi_ticket = @client.get_jsapi_ticket access_token
    @signature = @client.get_signature jsapi_ticket['ticket'], url
    render json: @signature
  end

  # 获取钉钉的用户信息，包括钉钉用户的userid
  def ding_user_info
    code = params[:code]
    @client = Client.new
    access_token = @client.get_access_token
    ding_user_info = @client.get_user_info access_token, code
    ding_user_id =ding_user_info['userid']
    message = {userid: ding_user_id, device_id: ding_user_info['deviceId'], errcode: ding_user_info['errcode'], errmsg: ding_user_info['errmsg'], is_sys: ding_user_info['is_sys'], sys_level: ding_user_info['sys_level']}
    render json: message
  end

  #发送消息
  def send_message_touser
    @client = Client.new
    response =  @client.send_message_touser params[:ding_id],params[:content]
    render json: response
  end

end
