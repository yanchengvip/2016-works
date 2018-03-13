class HomesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :is_login, only: :task

  def index

  end

  def home

  end

  # 页面推广分享
  def tuiguang
    code = params[:code]
    openid = User.get_openid code
    @user = User.find_by({OpenID: openid}) if !openid.nil?
    if @user
      mobile = @user.Mobile
      name = @user.Name
    else
      mobile = 13716417688
      name = '李经理'
    end

   redirect_to Settings.weixin.web_tui_guang +  URI.encode("?t=#{Time.now.to_i}mobile=#{mobile}&name=#{name}") and return
  end

  # 业务员系统
  def task
    remember_token = params[:remember_token]
    redirect_to Settings.weixin.jhtwebchat + "?remember_token=#{remember_token}&status=4"
  end


  # 新手入门
  def help
    #url值必须与调用微信jssdk页面的location.href.split('#')[0]的值一样，否则签名无效
    # url = 'http://yc.tunnel.jinhuobao.com.cn/homes/help/?' + request.url.split('?')[1]
    #http://yc.tunnel.jinhuobao.com.cn/homes/help/?code=021gSPAs0iL7Ar1TApxs09uVAs0gSPAG&state=weixin
    #@sign_package = $weixin.get_jssign_package(url)
    redirect_to Settings.weixin.help
  end

  # 提醒弹出框
  def tips
    @message = "您的账号有异常信息，暂时无法登陆，请在公众号留言[账号异常]，或联系客服"
  end

  # 重新登陆，获取token,或者跳转
  def login_again
    code = params[:code]
    openid = User.get_openid code
    @user = User.find_by({OpenID: openid}) if !openid.nil?
    get_remember_token @user
  end


  private

  def get_remember_token user

    if !user.present?
      # 微信未注册,跳回注册界面
      redirect_to $weixin.authorize_url(Settings.weixin.signup) and return
    end

    if user.IsDisabled
      # 账号被禁用
      @message = '账号被禁用'
      redirect_to $weixin.authorize_url(Settings.weixin.tips) and return
    end

    remember_token = User.new_remember_token
    sign_in user, remember_token
    case user.Status.to_i

      when 10
        # 注册成功，但未认证
        redirect_to URI.encode(Settings.weixin.jhtwebchat + "?remember_token=#{remember_token}&status=1&message=注册成功,但未认证") and return
      when 20
        #账号正在审核
        redirect_to URI.encode(Settings.weixin.jhtwebchat + "?remember_token=#{remember_token}&status=2&message=账号正在审核") and return
      when 30
        # 登陆成功
        #自动分配任务
        assgign_new_tasks = Thread.new {
          Task.assign_new_tasks user
        }
        assgign_new_tasks.join

        # status = 3
        # old_token = ''
        # redirect_to URI.encode(Settings.weixin.jhtwebchat + "?remember_token=#{remember_token}&is_older=#{status}&old_token=#{old_token}&status=3&message=登陆成功") and return
        redirect_to URI.encode(Settings.weixin.jhtwebchat + "?remember_token=#{remember_token}&status=3&message=登陆成功") and return

    end


  end
end
