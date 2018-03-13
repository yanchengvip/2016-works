#判断是否有审批的权限
if !@is_menu[:is_allowed]
  json.status 'error'
  json.message '没有此权限'
else
  json.status 'ok'
  json.data do
    json.array! @sm_users.each do |sm_user|
      json.id sm_user.ID
      json.name sm_user.Name
      json.mobile sm_user.Mobile
      json.province sm_user.province.ProvinceName
      json.city sm_user.city.CityName
      json.county sm_user.county.CountyName
      json.id_card_no sm_user.IDcardNo
      json.bank_card_no sm_user.BankCardNo
      json.bank_account sm_user.BankAccount
      json.bank_province sm_user.BankProvince
      json.bank_city sm_user.BankCity
      json.bank_branch sm_user.BankBranch
      json.id_card_pic sm_user.IDcardPic
      json.bank_card_pic sm_user.BandCardPic
      json.create_time sm_user.CreateTime ? sm_user.CreateTime.strftime('%Y-%m-%d %H:%M:%S') : ''
    end
  end
end