# 实例化缓存cache
$cache = Rails.cache


# 初始化 WeixinAuthorize::Client 的实例，传入公众账号的app_id跟app_secret即可。
# 创建一个实例
$weixin ||= WeixinAuthorize::Client.new(Settings.weixin.appID, Settings.weixin.appsecret,redis_key: "weixin_token")