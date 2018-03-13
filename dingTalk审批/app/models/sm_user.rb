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
#Status字段 { 10 => '审核失败' ,20 => '审核中', 30 => '审核通过' }
class SMUser < ActiveRecord::Base
  self.table_name = 'SMUsers'
  include UUIDHelper
  belongs_to :province, foreign_key: 'ProvinceID'
  belongs_to :city, foreign_key: 'CityID'
  belongs_to :county, foreign_key: 'CountyID'

  # 记录user创建log
  def sm_user_log
    SMUserLog.create(SMUserID:self.ID,SMUserStatus:20,Remark:'注册成功',
                     CreateTime:Time.now,UpdateTime:Time.now,RealName:self.Name,
                     IDCard:self.IDcardNo,BankCard:self.BankCardNo,Mobile:self.Mobile)

  end
end
