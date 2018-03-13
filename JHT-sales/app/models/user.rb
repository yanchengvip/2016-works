=begin
Table: SMUsers
Columns:
ID	char(36) PK
Mobile	varchar(255)
Password	varchar(255)
ProvinceID	varchar(255)
CityID	varchar(255)
CountyID	varchar(255)
Name	varchar(255)
IDcardNo	varchar(255)
IDcardPic	varchar(255)
BankCardNo	varchar(255)
BandCardPic	varchar(255)
InvitationCode	varchar(255)
Status	bigint(1)
AuditedTime	datetime
CompanyID	char(36)
CreateTime	datetime
CreateBy	varchar(100)
UpdateTime	datetime
UpdateBy	varchar(100)
IsDisabled 是否禁用 0：正常,1:禁用
=end


# Status = 30 为激活用户

# 微信端 业务员用户表
#Status字段 { 10 => '注册成功，但未认证' ,20 => '认证中', 30 => '认证通过' }
class User < ActiveRecord::Base
  self.table_name = 'users'
  include UUIDHelper
  include Users::WeixinHelper
  include Users::OrderHelper

  attr_accessor :check_code
  attr_accessor :remember_token

  has_many :user_tasks, foreign_key: 'UserID'
  has_many :tasks, through: :user_tasks, foreign_key: 'UserID'
  has_many :user_orders, foreign_key: 'UserID'
  has_many :user_relations, foreign_key: 'UserID'
  has_one :user_relation, foreign_key: 'RelationUserID'

  before_create :user_status
  after_create :user_log
  validates :Mobile, presence: true, uniqueness: {message: '手机号不能重复'}
  # validates :Password, format:{with: /\S{6,}/,message:'密码无效'}
  #validates :IDcardNo, presence: true, uniqueness: {message: '身份证已注册使用'},on: :update
  # validates :SceneID, presence: true, uniqueness: {message: '微信二维码的SceneID已存在'},on: :update
  validates :OpenID, presence: true, uniqueness: {message: '微信号已注册使用'}, on: :create

  def update_password old_password, new_password, password_confirmation
    if self.Password == old_password
      if new_password.nil? || password_confirmation.nil? || new_password != password_confirmation
        result = {status: 'error', message: '密码不一致'}
      else
        flag = self.update_attributes({Password: new_password})
        if flag
          result = {status: 'ok', message: '修改成功'}
        else
          result = {status: 'error', message: '修改失败'}
        end

      end

    else
      result = {status: 'error', message: '旧密码错误'}
    end
    return result
  end


  # 身份证和卡号一致性验证
  def self.verify_card_bank name, id_card_no, bank_card_no
    url = URI.encode("#{Settings.verifybankcard}&realname=#{name}&idcard=#{id_card_no}&bankcard=#{bank_card_no}")
    response_v = HTTParty.get(url, :headers => {'Content-Type' => 'application/json'})
    response_v = JSON.parse(response_v.body)['result']
  end


  private

  # 返回一个随机令牌
  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  # 返回指定字符串的摘要
  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end


  #  新注册的用户，默认状态为status=10(注册成功，但未审核)
  def user_status
    # self.Status = 10
    self.IsDisabled = 0
  end


  # 记录user创建log
  def user_log
    UserLog.create(UserID: self.ID, UserStatus: 10, Remark: '注册成功',
                   CreateTime: Time.now, UpdateTime: Time.now, RealName: self.Name,
                   IDCard: self.IDcardNo, BankCard: self.BankCardNo, Mobile: self.Mobile)

  end
end
