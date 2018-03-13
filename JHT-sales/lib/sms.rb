module Sms
    extend self
  def send_check_code mobile
    code = (rand(9000) + 1000).to_s
    $cache.write("#{mobile}_check_code", code, :expires_in => 1.minutes)
    if Settings.sms.enable
      result = Cloopen::SMS.deliver(mobile, Settings.sms.check_code_template, [code, Settings.sms.expire_in])
      # result返回值为['000000',null]代表发送成功，["160038","短信验证码发送过频繁"]失败，等等
      if result.first == '000000'
        # 发送成功，验证码保存到缓存，30分钟后失效
        $cache.write("#{mobile}_check_code", code, :expire_in => Settings.sms.expire_in.minutes)
      end
      return result
    end
  end
end
