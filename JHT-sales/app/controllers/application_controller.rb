class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  skip_before_action :verify_authenticity_token

  def is_login

    if !sign_in?
      url = $weixin.authorize_url(Settings.weixin.login_again)
      # redirect_to 'https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxe56816642b505d6f&redirect_uri=http://yc.tunnel.jinhuobao.com.cn/homes/help&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect'
      redirect_to  url
    end

  end
end
