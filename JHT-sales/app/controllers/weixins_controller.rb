class WeixinsController < ApplicationController
  # 结合: https://github.com/lanrion/weixin_authorize(建议选用此gem的Redis存access_token方案)
  skip_before_filter :verify_authenticity_token
  before_action :is_login, only: [:create_qrcode]

  def create_menus
    # 创建一个实例
    # $weixin ||= WeixinAuthorize::Client.new(Settings.weixin.appID, Settings.weixin.appsecret)
    # 为了避免用户填写app_id和app_secret出错，请务必在初始化client时，对其做验证，注意：不是每次调用微信API时调用。
    # @flag = $weixin.is_valid? #返回true或false
    menu = WeixinMenu.build_menu
    result = $weixin.create_menu(menu)
    render json: result
  end


  # 永久素材列表
  def material_list
    # 永久素材的数量是有上限的，请谨慎新增。图文消息素材和图片素材的上限为5000，其他类型为1000
    type = params[:type] ? params[:type] : 'news' #默认图文素材
    offset = params[:offset] ? params[:offset] : 0 #默认从0开始罗列
    count = params[:count] ? params[:count] : 5000 #默认查询所有素材
    list = $weixin.http_post('/material/batchget_material', {type: type, offset: offset, count: count})
    render json: list
  end

  # 推送微信消息
  def send_weixin_message

    options = {
        openid: params[:openid],
        status: params[:status],
        content: params[:content]
    }
    flag = WeixinMenu.send_template_message options
    render json: flag
  end

  def send_weixin_message_by_order
    order_id = params['order_id']
    status = params['status']
    content = params['content']
    response = WeixinMenu.send_weixin_message_by_order order_id,status,content
    render json: response
  end


  # 根据用户ID生成对应二维码
  def get_qrcode
     url =  current_user.create_qrcode
    render json: url
  end

  def get_weixin_code
    url = $weixin.authorize_url(Settings.weixin.get_weixin_code_by_url)
    redirect_to  url
  end

  def get_weixin_code_by_url
    code = params[:code]
    render json:{status: 1,code: code}
  end

  # 微信签名 页面调用jssdk
  def weixin_jssign_package
    # 要确保request.url与location.href.split('#')[0]一样，否则会报invalid signature签名错误
    #   需要调用jssdk当前页面完整的url
    #   alert(location.href.split('#')[0])
    @sign_package = $weixin.get_jssign_package(params[:url])
    render json: @sign_package
  end
end
