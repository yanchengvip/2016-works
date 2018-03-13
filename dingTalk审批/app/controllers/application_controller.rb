class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  include SessionsHelper

  def is_login
    if !sign_in?
      # 未登录，需要前端进行跳转，后台跳转无效
      render json: {status:'ok',is_login:false,content:'用户未登陆'}
    end
  end


end
