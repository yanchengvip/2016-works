=begin
Table: SMMenus
Columns:
ID	char(36) PK
Name	varchar(255)
Level	int(11)
Parent	char(36)
Title	varchar(255)
ResponseType	int(11)
MediaID	varchar(255)
MediaName	varchar(255)
Description	text
CoverPic	varchar(255)
NewsLink	varchar(255)
Status	int(11)
CreateTime	datetime
CreateBy	varchar(100)
UpdateTime	datetime
UpdateBy	varchar(100)
Sort	int(11)


#ResponseType 回复类型（0=>文字 | 1=>图文 | 2=>跳转网页 | 3=>扫一扫）
=end
# 微信端 菜单列表
class WeixinMenu < ActiveRecord::Base
  self.table_name = 'weixin_menus'

  has_many :sub_menus, ->{where(Status: 1).order("Sort asc").limit(5)}, class_name: "WeixinMenu", foreign_key: :Parent
  belongs_to :parent, class_name: "WeixinMenu",foreign_key: :Parent

  CLICK_TYPE = "click" # key 文字
  MEDIA_ID_TYPE = "media_id" # 图文
  VIEW_TYPE  = "view" # url 跳转网页
  SCANCODE_PUSH_TYPE = "scancode_push" #扫一扫
  # 生成微信菜单json,Level=0为一级菜单
  def self.build_menu
    parent_menus = WeixinMenu.where(Level:0,MediaID:nil,Status:1).order('Sort asc')
    Jbuilder.encode do |json|
      json.button (parent_menus) do |menu|
        json.name menu.Name
        if menu.has_sub_menu?
          json.sub_button (menu.sub_menus) do |sub_menu|
            json.name sub_menu.Name
            if sub_menu.ResponseType.to_i == 0
              json.type CLICK_TYPE
              json.key  sub_menu.Description

            elsif sub_menu.ResponseType.to_i == 1
              json.type MEDIA_ID_TYPE
              json.media_id sub_menu.MediaID

            elsif sub_menu.ResponseType.to_i == 2
              json.type VIEW_TYPE
              json.url $weixin.authorize_url(sub_menu.NewsLink) #authorize_url会生成获取code的链接  https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxe56816642b505d6f&redirect_uri=http://yc.tunnel.jinhuobao.com.cn/signup&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect
            elsif sub_menu.ResponseType.to_i == 3
              json.type SCANCODE_PUSH_TYPE
              json.media_id sub_menu.MediaID
            else
              json.type CLICK_TYPE
              json.key '没有定义此按钮的相应类型'
            end


          end
        else
          json.type VIEW_TYPE
          json.url $weixin.authorize_url(menu.NewsLink)
        end
      end
    end
  end


  def has_sub_menu?
    self.sub_menus.present?
  end


  # 根据订单id发送给相应用户微信消息
  def self.send_weixin_message_by_order order_id,status,content
    user_order = UserOrder.where(OrderID: order_id)
    if user_order.empty?
      return {status:0,message: '消息不能推送，此订单未绑定,没有相应的用户',code:100,en_msg:'error',cn_msg:'消息不能推送，此订单未绑定,没有相应的用户'}
    end

    openid = User.find(user_order.first.UserID).OpenID
    options = {
        openid: openid,
        status: status,
        content: content
    }
    response = WeixinMenu.send_template_message options
    return response
  end


  #   发送消息模板
  def self.send_template_message options
    openid = options[:openid]
    status = options[:status]
    content = options[:content]
    order_money = options[:order_money]
    order_code = options[:order_code]
    ship_name = options[:ship_name]
    ship_tel = options[:ship_tel]
    return_products_names = options[:return_products_names]


    @user = User.where(OpenID:openid).first
    case status.to_i
      when 1
        # 审核失败通知
        data={
            first: {
                value:"抱歉审核失败",
                color:"#173177"
            },
            keyword1:{
                value:@user.Name,
                color:"#173177"
            },
            keyword2:{
                value:content,
                color:"#173177"
            },
            keyword3:{
                value:Time.now.strftime('%Y-%m-%d %H:%M'),
                color:"#173177"
            },
            remark:{
                value:"您的帐号审核未通过，请您重新提交。",
                color:"#173177"
            }

        }
        url = $weixin.authorize_url(Settings.weixin.signup)
        template_id = Settings.weixin.template1
        response = $weixin.send_template_msg(openid, template_id, url, 'red', data)
      when 2
        #审核成功通知
        data={
            first: {
                value:"审核成功",
                color:"#173177"
            },
            keyword1:{
                value:@user.Name,
                color:"#173177"
            },
            keyword2:{
                value:'恭喜您审核通过',
                color:"#173177"
            },
            keyword3:{
                value:Time.now.strftime('%Y-%m-%d %H:%M'),
                color:"#173177"
            },
            remark:{
                value:"点击进入",
                color:"#173177"
            }

        }
        url = $weixin.authorize_url(Settings.weixin.user_task_home)
        template_id = Settings.weixin.template2
        response = $weixin.send_template_msg(openid, template_id, url, 'red', data)
      when 3
        #订单退货通知
        data={
            first: {
                value:"您好，有新的退货通知",
                color:"#173177"
            },
            keyword1:{
                value:order_code,
                color:"#173177"
            },

            keyword2:{
                value:ship_name,
                color:"#173177"
            },
            keyword3:{
                value:ship_tel,
                color:"#173177"
            },
            keyword4:{
                value:return_products_names,
                color:"#173177"
            },
            remark:{
                value:'退货详情',
                color:"#173177"
            }

        }
        url = ''
        template_id = Settings.weixin.template3
        response = $weixin.send_template_msg(openid, template_id, url, 'red', data)
      when 4
        #订单取消通知
        data={
            first: {
                value:"您好，有新的退货通知",
                color:"#173177"
            },
            keyword1:{
                value:order_money,
                color:"#173177"
            },

            keyword2:{
                value:ship_name,
                color:"#173177"
            },
            keyword3:{
                value:ship_tel,
                color:"#173177"
            },
            keyword4:{
                value:order_code,
                color:"#173177"
            },
            remark:{
                value: content,
                color:"#173177"
            }

        }
        url = ''
        template_id = Settings.weixin.template4
        response = $weixin.send_template_msg(openid, template_id, url, 'red', data)


      when 8
        #订单状态变化
        response = $weixin.send_text_custom(openid,content)
      else
        response = {en_msg:'error',cn_msg:'请求失败',result:{content:'没有对应的模板'}}
    end
    return response

    #   {"code":0,"en_msg":"ok","cn_msg":"请求成功","result":{"msgid":431333709}}
  end
end
