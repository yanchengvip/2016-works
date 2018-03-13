module SessionsHelper
  def sign_in(user, remember_token)
    user.update_attributes({RememberToken: User.encrypt(remember_token)})
    self.current_user = user
  end


  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = params[:remember_token]
    # 先根据openid验证用户是否存在，存在则默认登陆
    @current_user ||= User.find_by({RememberToken: User.encrypt(remember_token), Status: 30}) if remember_token
  end

  def sign_in?
    !current_user.nil?
  end

  def current_user?(user)
    user == current_user
  end


end
