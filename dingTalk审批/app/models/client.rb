class Client
    include DingJsApi

  # 获取企业访问钉钉的access_token
  def get_access_token
    response = HTTParty.get("https://oapi.dingtalk.com/gettoken?corpid=#{Settings.ding_talk.corpid}&corpsecret=#{Settings.ding_talk.corpsecret}",
                            :headers => {'Content-Type' => 'application/json'})
    response['access_token']
  end

  # 通过CODE换取用户信息
  def get_user_info access_token, code
    response = HTTParty.get("https://oapi.dingtalk.com/user/getuserinfo?access_token=#{access_token}&code=#{code}",
                            :headers => {'Content-Type' => 'application/json'})
  end

  def send_message_touser  ding_id,content
    access_token = get_access_token
    response = HTTParty.post("https://oapi.dingtalk.com/message/send?access_token=#{access_token}",
                             :body => {:touser => ding_id,
                                       :agentid => Settings.order_agentId,
                                       :msgtype => 'text',
                                       :text => {content: content}
                             }.to_json,
                             :headers => {'Content-Type' => 'application/json', })
  end

  # # 获取用户授权的持久授权码
  # def get_persistent_code app_access_token, code
  #   response = HTTParty.post("https://oapi.dingtalk.com/sns/get_persistent_code?access_token=#{app_access_token}",
  #                            :body => { :tmp_auth_code => code
  #                            }.to_json,
  #                            :headers => { 'Content-Type' => 'application/json' } )
  #
  #   #  response =  {"errcode": 0,"errmsg": "ok","openid": "Lt79qBzHJhPTov18cHoPuQiEiE","persistent_code": "5lGC8kY1Jgf1s-U0oPXPzud92AuPXPhWiVOSLowED1OxPwm9HMiCFgMlatTy_2X5","unionid": "jsh6wd2H8TnlM0VPBSynNgiEiE"}
  #
  # end
end