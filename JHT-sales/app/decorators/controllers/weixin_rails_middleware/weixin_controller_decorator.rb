# encoding: utf-8
# 1, @weixin_message: 获取微信所有参数.
# 2, @weixin_public_account: 如果配置了public_account_class选项,则会返回当前实例,否则返回nil.
# 3, @keyword: 目前微信只有这三种情况存在关键字: 文本消息, 事件推送, 接收语音识别结果
WeixinRailsMiddleware::WeixinController.class_eval do

  def reply
    render xml: send("response_#{@weixin_message.MsgType}_message", {})
  end

  private

  def response_text_message(options={})
    is_contain1 = @keyword =~ /(.*)下载(.*)/
    is_contain2 = @keyword =~ /(.*)下单(.*)/
    is_contain3 = @keyword =~ /(.*)付款(.*)/
    is_contain4 = @keyword =~ /(.*)到帐(.*)/
    is_contain5 = @keyword =~ /(\d{11})\s*(\d{4})/
    if is_contain1
      reply_text_message("<a href='http://mp.weixin.qq.com/s?__biz=MzI3MTIyMzI0Mw==&mid=100000025&idx=1&sn=5f476da26bc0db3a1a6bdf8bfea76ba5#rd'>下载进货宝APP</a>")
    elsif is_contain2
      reply_text_message("<a href = 'http://mp.weixin.qq.com/s?__biz=MzI3MTIyMzI0Mw==&mid=100000006&idx=1&sn=3814b67afdde1d57b1296e7e100a5c2e#rd'>了解如何通过进货宝下单</a>")
    elsif is_contain3
      reply_text_message("<a href= 'http://mp.weixin.qq.com/s?__biz=MzI3MTIyMzI0Mw==&mid=100000008&idx=1&sn=e24e6bba0d14456f0e64482fd285bf23#rd'>了解门店收货付款方式</a>")
    elsif is_contain4
      reply_text_message("查询收入到帐时间")

    else
      #reply_text_message("Your Message: #{@keyword}")
      reply_text_message("欢迎关注进货团共享平台！详情可咨询：010-58349228 在线时间：周一至周五9:00~18:00")
    end
  end


  # <Location_X>23.134521</Location_X>
  # <Location_Y>113.358803</Location_Y>
  # <Scale>20</Scale>
  # <Label><![CDATA[位置信息]]></Label>
  def response_location_message(options={})
    @lx = @weixin_message.Location_X
    @ly = @weixin_message.Location_Y
    @scale = @weixin_message.Scale
    @label = @weixin_message.Label
    reply_text_message("Your Location: #{@lx}, #{@ly}, #{@scale}, #{@label}")
  end

  # <PicUrl><![CDATA[this is a url]]></PicUrl>
  # <MediaId><![CDATA[media_id]]></MediaId>
  def response_image_message(options={})
    @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
    @pic_url = @weixin_message.PicUrl # 也可以直接通过此链接下载图片, 建议使用carrierwave.
    reply_image_message(generate_image(@media_id))
  end

  # <Title><![CDATA[公众平台官网链接]]></Title>
  # <Description><![CDATA[公众平台官网链接]]></Description>
  # <Url><![CDATA[url]]></Url>
  def response_link_message(options={})
    @title = @weixin_message.Title
    @desc = @weixin_message.Description
    @url = @weixin_message.Url
    reply_text_message("回复链接信息")
  end

  # <MediaId><![CDATA[media_id]]></MediaId>
  # <Format><![CDATA[Format]]></Format>
  def response_voice_message(options={})
    @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
    @format = @weixin_message.Format
    # 如果开启了语音翻译功能，@keyword则为翻译的结果
    # reply_text_message("回复语音信息: #{@keyword}")
    reply_voice_message(generate_voice(@media_id))
  end

  # <MediaId><![CDATA[media_id]]></MediaId>
  # <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
  def response_video_message(options={})
    @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
    # 视频消息缩略图的媒体id，可以调用多媒体文件下载接口拉取数据。
    @thumb_media_id = @weixin_message.ThumbMediaId
    reply_text_message("回复视频信息")
  end

  def response_event_message(options={})
    event_type = @weixin_message.Event
    method_name = "handle_#{event_type.downcase}_event"
    if self.respond_to? method_name, true
      send(method_name)
    else
      send("handle_undefined_event")
    end
  end

  # 关注公众账号
  def handle_subscribe_event
    # if @keyword.present?
    #   # 扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送
    #   return reply_text_message("扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送, keyword: #{@keyword}")
    # end
    user = User.find_by(OpenID: @weixin_message.FromUserName)
    if user
      url = $weixin.authorize_url("#{Settings.weixin.user_task_home}?status=4")
      return reply_text_message("欢迎回来,您马上可以：<a href='#{url}'>>>点击进入进货团</a>")
    end
    url = $weixin.authorize_url(Settings.weixin.user_task_home)
    reply_text_message("欢迎关注进货团微信企业号，您马上可以：<a href='#{url}'>>>点击进入进货团</a>")
    # reply_text_message("欢迎关注进货团微信企业号，您马上可以：
    #    <a href='https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{Settings.weixin.appID}&redirect_uri=#{Settings.weixin.jhtwebchat}&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect'>>>注册进货团</a>")
  end

  # 取消关注
  def handle_unsubscribe_event
    Rails.logger.info("取消关注")
    reply_text_message("")
  end

  # 扫描带参数二维码事件: 2. 用户已关注时的事件推送
  def handle_scan_event
    #reply_text_message("扫描带参数二维码事件: 2. 用户已关注时的事件推送, keyword: #{@keyword}")
    scene_id = @keyword
    openid = @weixin_message.FromUserName
    message = User.bind_user openid, scene_id
    reply_text_message(message)
  end

  def handle_location_event # 上报地理位置事件
    @lat = @weixin_message.Latitude
    @lgt = @weixin_message.Longitude
    @precision = @weixin_message.Precision
    reply_text_message("Your Location: #{@lat}, #{@lgt}, #{@precision}")
  end

  # 点击菜单拉取消息时的事件推送
  def handle_click_event
    reply_text_message("#{@keyword}")
  end

  # 点击菜单跳转链接时的事件推送
  def handle_view_event
    Rails.logger.info("#{@keyword}")
    reply_text_message("")
  end

  # 帮助文档: https://github.com/lanrion/weixin_authorize/issues/22

  # 由于群发任务提交后，群发任务可能在一定时间后才完成，因此，群发接口调用时，仅会给出群发任务是否提交成功的提示，若群发任务提交成功，则在群发任务结束时，会向开发者在公众平台填写的开发者URL（callback URL）推送事件。

  # 推送的XML结构如下（发送成功时）：

  # <xml>
  # <ToUserName><![CDATA[gh_3e8adccde292]]></ToUserName>
  # <FromUserName><![CDATA[oR5Gjjl_eiZoUpGozMo7dbBJ362A]]></FromUserName>
  # <CreateTime>1394524295</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[MASSSENDJOBFINISH]]></Event>
  # <MsgID>1988</MsgID>
  # <Status><![CDATA[sendsuccess]]></Status>
  # <TotalCount>100</TotalCount>
  # <FilterCount>80</FilterCount>
  # <SentCount>75</SentCount>
  # <ErrorCount>5</ErrorCount>
  # </xml>
  def handle_masssendjobfinish_event
    Rails.logger.info("回调事件处理")
    reply_text_message("")
  end

  # <xml>
  # <ToUserName><![CDATA[gh_7f083739789a]]></ToUserName>
  # <FromUserName><![CDATA[oia2TjuEGTNoeX76QEjQNrcURxG8]]></FromUserName>
  # <CreateTime>1395658920</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[TEMPLATESENDJOBFINISH]]></Event>
  # <MsgID>200163836</MsgID>
  # <Status><![CDATA[success]]></Status>
  # </xml>
  # 推送模板信息回调，通知服务器是否成功推送
  def handle_templatesendjobfinish_event
    Rails.logger.info("回调事件处理")
    reply_text_message("")
  end

  # <xml>
  # <ToUserName><![CDATA[toUser]]></ToUserName>
  # <FromUserName><![CDATA[FromUser]]></FromUserName>
  # <CreateTime>123456789</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[card_pass_check]]></Event>  //不通过为card_not_pass_check
  # <CardId><![CDATA[cardid]]></CardId>
  # </xml>
  # 卡券审核事件，通知服务器卡券已(未)通过审核
  def handle_card_pass_check_event
    Rails.logger.info("回调事件处理")
    reply_text_message("")
  end

  def handle_card_not_pass_check_event
    Rails.logger.info("回调事件处理")
    reply_text_message("")
  end

  # <xml>
  # <ToUserName><![CDATA[toUser]]></ToUserName>
  # <FromUserName><![CDATA[FromUser]]></FromUserName>
  # <FriendUserName><![CDATA[FriendUser]]></FriendUserName>
  # <CreateTime>123456789</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[user_get_card]]></Event>
  # <CardId><![CDATA[cardid]]></CardId>
  # <IsGiveByFriend>1</IsGiveByFriend>
  # <UserCardCode><![CDATA[12312312]]></UserCardCode>
  # <OuterId>0</OuterId>
  # </xml>
  # 卡券领取事件推送
  def handle_user_get_card_event
    Rails.logger.info("回调事件处理")
    reply_text_message("")
  end

  # <xml>
  # <ToUserName><![CDATA[toUser]]></ToUserName>
  # <FromUserName><![CDATA[FromUser]]></FromUserName>
  # <CreateTime>123456789</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[user_del_card]]></Event>
  # <CardId><![CDATA[cardid]]></CardId>
  # <UserCardCode><![CDATA[12312312]]></UserCardCode>
  # </xml>
  # 卡券删除事件推送
  def handle_user_del_card_event
    Rails.logger.info("回调事件处理")
    reply_text_message("")
  end

  # <xml>
  # <ToUserName><![CDATA[toUser]]></ToUserName>
  # <FromUserName><![CDATA[FromUser]]></FromUserName>
  # <CreateTime>123456789</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[user_consume_card]]></Event>
  # <CardId><![CDATA[cardid]]></CardId>
  # <UserCardCode><![CDATA[12312312]]></UserCardCode>
  # <ConsumeSource><![CDATA[(FROM_API)]]></ConsumeSource>
  # </xml>
  # 卡券核销事件推送
  def handle_user_consume_card_event
    Rails.logger.info("回调事件处理")
  end

  # <xml>
  # <ToUserName><![CDATA[toUser]]></ToUserName>
  # <FromUserName><![CDATA[FromUser]]></FromUserName>
  # <CreateTime>123456789</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[user_view_card]]></Event>
  # <CardId><![CDATA[cardid]]></CardId>
  # <UserCardCode><![CDATA[12312312]]></UserCardCode>
  # </xml>
  # 卡券进入会员卡事件推送
  def handle_user_view_card_event
    Rails.logger.info("回调事件处理")
  end

  # <xml>
  # <ToUserName><![CDATA[toUser]]></ToUserName>
  # <FromUserName><![CDATA[FromUser]]></FromUserName>
  # <CreateTime>123456789</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[user_enter_session_from_card]]></Event>
  # <CardId><![CDATA[cardid]]></CardId>
  # <UserCardCode><![CDATA[12312312]]></UserCardCode>
  # </xml>
  # 从卡券进入公众号会话事件推送
  def handle_user_enter_session_from_card_event
    Rails.logger.info("回调事件处理")
  end

  # <xml>
  # <ToUserName><![CDATA[toUser]]></ToUserName>
  # <FromUserName><![CDATA[fromUser]]></FromUserName>
  # <CreateTime>1408622107</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[poi_check_notify]]></Event>
  # <UniqId><![CDATA[123adb]]></UniqId>
  # <PoiId><![CDATA[123123]]></PoiId>
  # <Result><![CDATA[fail]]></Result>
  # <Msg><![CDATA[xxxxxx]]></Msg>
  # </xml>
  # 门店审核事件推送
  def handle_poi_check_notify_event
    Rails.logger.info("回调事件处理")
  end

  # 未定义的事件处理
  def handle_undefined_event
    Rails.logger.info("回调事件处理")
    reply_text_message("")
  end

end
