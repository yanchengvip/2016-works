module DingJsApi

  # 获取ticket
  def get_jsapi_ticket access_token
    response = HTTParty.get("https://oapi.dingtalk.com/get_jsapi_ticket?access_token=#{access_token}",
                            :headers => {'Content-Type' => 'application/json'}
    )
  end

  # 获取签名
  def get_signature jsticket, url
    timestamp = Time.now.to_i
    noncestr = SecureRandom.hex(16)
    # url = 'http://yc.tunnel.jinhuobao.com.cn/users' #当前网页的url
    agentId = Settings.order_agentId
    # 为了返回不同的agentid，用来区分前端跳转不同的微应用
    if url.include?('order')
      agentId = Settings.order_agentId
    end
    if url.include?('price')
      agentId = Settings.price_agentId
    end
    if url.include?('salesman')
      agentId = Settings.salesman_agentId
    end
    str = "jsapi_ticket=#{jsticket}&noncestr=#{noncestr}&timestamp=#{timestamp}&url=#{url}";
    signature = Digest::SHA1.hexdigest(str)
    @signature = {
        agentId: agentId, # 必填，微应用ID
        corpId: Settings.ding_talk.corpid, #必填，企业ID
        timeStamp: timestamp, # 必填，生成签名的时间戳
        nonceStr: noncestr, # 必填，生成签名的随机串
        signature: signature, #必填，签名
        jsApiList: ['device.notification.alert', 'device.notification.confirm'] # 必填，需要使用的jsapi列表
    }
  end

end