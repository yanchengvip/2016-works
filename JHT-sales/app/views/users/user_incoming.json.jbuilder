json.status 'ok'
json.name @user.Name #用户姓名
json.user_logo @user_logo #用户的微信头像
json.balanced @balanced #用户已结算的收入
json.no_balanced @no_balanced #用户未结算收入
json.qrcode_url @url #用户的临时二维码地址