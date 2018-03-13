module Users
  module WeixinHelper
    extend ActiveSupport::Concern



    # 获取微信用户的openid
    def User.get_openid code
      sns_info = $weixin.get_oauth_access_token(code)
      openid = sns_info.result[:openid]
      return openid
    end

    # 生成用户对应的临时二维码
    def create_qrcode
      # 创建临时二维码,二维码有效期3600秒即60分钟
      if self.SceneID.present?
        # 确保每次获得的二维码的SceneID保持一致
        rand = self.SceneID
      else
        begin
          rand = Time.new.to_i
          #确保SceneID的唯一性,没有重复的SceneID，则flag为true，失败则flag为false
          flag = User.where(SceneID: rand).empty?
        end while !flag

        self.update_attributes(SceneID: rand) #SceneID的唯一性
      end
      response = $weixin.create_qr_scene(rand, 3600)
      #通过ticket换取二维码, 直接访问返回的链接即可显示
      ticket = response.as_json['result']['ticket']
      url = $weixin.qr_code_url(ticket)
      return url

    end


    # 扫二维码加好友,普通业务员扫二维码加推广员,openid为普通业务员的,scene_id为推广员
    def User.bind_user openid, scene_id
      @relation_user = User.find_by(Openid: openid)
      # 确保被加的人是 推广员
      @extent_user = User.where(SceneID: scene_id.to_i, UserType: 1).first
      return '您扫描的二维码对应的用户不是推广员!如有疑问请联系客服010-67832728' if @extent_user.nil?

      # 如果普通业务员没有注册,先记录openid和推广员的关系,然后在注册时,根据openid,主动绑定
      if @relation_user.nil?
        relation_user = UserRelation.find_by(RelationUserOpenID: openid)
        if relation_user
          relation_user.update_columns(UserID: @extent_user.ID)
        else
          user_relation = UserRelation.new(UserID: @extent_user.ID, RelationUserOpenID: openid)
          user_relation.save(validate: false)
        end
        reply_message = "您尚未注册!您马上可以：<a href='#{$weixin.authorize_url(Settings.weixin.user_task_home)}'>>>点击进入进货团</a>"
        return reply_message
      end


      #确保两个用户之前没有关系,此业务员仅被加一次
      user_relation = UserRelation.where(RelationUserID: @relation_user.ID).first

      return "您已经有推广员了，推广员是#{user_relation.user.Name}，如有疑问请联系客服010-67832728" if user_relation

      user_realtion_atrr = {UserID: @extent_user.ID, RelationUserID: @relation_user.ID}
      flag = UserRelation.create(user_realtion_atrr)
      message = "恭喜您成功关注了推广员:#{@extent_user.Name}" if flag
      message = '很遗憾...绑定失败,请重新再试一次!如有疑问请联系客服010-67832728' if !flag
      begin
        $weixin.send_text_custom(@extent_user.OpenID, "恭喜您被名字为[#{@relation_user.Name}]的业务员成功关注!")
      rescue

      end
      return message
    end


    # 注册时自动关注推广员/前提是:注册前已经扫了推广员的二维码
    def guanzhu_user_by_openid
      begin
        user_relation =  UserRelation.find_by(RelationUserOpenID: self.OpenID)
        if user_relation
          user_relation.update_attributes(RelationUserID: self.ID)
        end
      rescue

      end
    end


    def User.qiniu_fetch media_id
      # 注意！注意！慎重使用$weixin.is_valid?方法，它会重新获取access_token,access_token每天只有2000次
      #$weixin.is_valid? #为了防止download_meidia_url不获取最新token,而报4001错误。
      from_url = $weixin.download_media_url(media_id)
      key = media_id #上传后文件的名字
      encode_from_url = Qiniu::Utils.urlsafe_base64_encode(from_url)
      encode_to_uri = Qiniu::Utils.encode_entry_uri(Settings.qiniu.bucket, key)
      path = "/fetch/#{encode_from_url}/to/#{encode_to_uri}"
      host = "iovip.qbox.me"
      access_token = Qiniu::Auth.generate_acctoken(path)
      authorization = "QBox #{access_token}"
      result = HTTParty.post("http://#{host}/fetch/#{encode_from_url}/to/#{encode_to_uri}",
                             :headers => {'Content-Type' => 'application/json', 'Authorization' => authorization})
      url = Settings.qiniu.qiniu_base_url + result['key']
    end



  end
end
