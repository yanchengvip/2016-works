
require('purecss')
require('./styles/base.scss')

import _ from 'lodash'
import Vue from 'vue'
import VueRouter from 'vue-router'

import Index from './components/index'
import MyTask from './components/task/my'
import Store from './components/parts/store'

import Header from './components/parts/header'
import FooterNav from './components/parts/footer'

import Loading from 'vux/src/components/loading'


window.getArugument = function(s) {
  var arr, i, pair, query, query_string, vars;
  query_string = {};
  // query = location.href.split('?')[1].split('#!')[0];
  query = window.location.search.substring(1)
  vars = query.split('&');
  i = 0;
  while (i < vars.length) {
    pair = vars[i].split('=');
    if (typeof query_string[pair[0]] === 'undefined') {
      query_string[pair[0]] = decodeURIComponent(pair[1]);
    } else if (typeof query_string[pair[0]] === 'string') {
      arr = [query_string[pair[0]], decodeURIComponent(pair[1])];
      query_string[pair[0]] = arr;
    } else {
      query_string[pair[0]].push(decodeURIComponent(pair[1]));
    }
    i++;
  }
  return query_string[s]
}




// 1.{
//     status: 1,
//     message: '注册成功，但未认证',
//     remember_token: 'xx'
// }
// 2.{
//     status: 2,
//     message: '认证中...',
//     remember_token: 'xx'
// }
// 3.{
//     status: 3,
//     message: '登陆成功',
//     remember_token: 'xx',
//     is_older: '是否是旧版本的用户1=否，2=是',
//     old_token: '旧版本token'
// }
// 4.{
//     status: 4,
//     message: '用户未注册'
// }

Vue.filter('substr',function(value){
  if (value) {
    return value.slice(0,10);
  }

})
window.saveToken = function () {
  try {
    let token = getArugument('remember_token')
    if (token) {
      window.TOKEN = token
      localStorage.setItem('token', token)
    }
  }
  catch (e) {
    return
  }
}

let checkAccountStatus = function () {
  let status = getArugument('status')
    if (status == 1 || status == 2) {
      location.hash = '#!/certification'
    } else if (status == 4) {
      location.hash = '#!/signup'
    }
}


checkAccountStatus()
window.saveToken()


let buildUrl = (path) => {
  if (path.slice(0, 4) == "http") {
    return path
  } else {
    return API_HOST + '/jht2' + path
  }
}


window.store = Store

let components = {
  'page-header': Header,
  'footer-nav': FooterNav,
  'loading': Loading
}

window._ = _
Vue.use(VueRouter)
Vue.use(require('vue-resource'))
Vue.use(require('vue-infinite-scroll'))
var App = Vue.extend({})
var router = new VueRouter()
window.Vue = Vue

Vue.config.debug = true


for (let key of Object.keys(components)) {
  Vue.component(key, components[key])
}

let API_HOST = "//xxx.com.cn/"
let HOST = 'http://xxx.com.cn/'
HOST = HOST + location.search
if (location.host == 'xxxcom.cn') {
  API_HOST = "//xxx.com.cn"
  HOST = location.href.replace(location.hash,"")
} else if (location.host == 'xxx.com.cn') {
  // console.log(HOST)
  API_HOST = "//rails.tunnel.jinhuobao.com.cn"
  HOST = location.href.replace(location.hash,"")
} else if (location.host == 'saleswx.ui-tech.com.cn') {
  API_HOST = "//sales.ui-tech.com.cn"
  HOST = location.href.replace(location.hash,"")
}


window.TOKEN = localStorage.getItem('token') || '1234567'

window.$ = function (s) {
  let i = document.querySelector(s)
  if (i) {
    i.css = window.getComputedStyle(i)
  }
  return i
}


Vue.http.interceptors.push((request, next)  => {
    if (request.method=="get") {
      request.params['remember_token'] = window.TOKEN
    } else {
      let data = request.body || {}
      data['remember_token'] = window.TOKEN
      request.body = data
    }
    request.url = buildUrl(request.url)
    next(function (res){
      let token = res.json().remember_token
      if (token) {
        window.TOKEN = token
        localStorage.setItem('token', token)
      }
      // alert(JSON.stringify(res.json()))
    })
})

router.map({
    '/': {
        component: Index
    },
    '/task/my': {
        component: MyTask
    },
    '/task/center': {
      component: function (resolve) {
        require(['./components/task/center.vue'], resolve)
      }
    },
    '/task/center/:id': {
      component: function (resolve) {
        require(['./components/task/center-detail.vue'], resolve)
      }
    },
    '/task/:id': {
      component: function (resolve) {
        require(['./components/task/detail.vue'], resolve)
      }
    },
    '/order/:id': {
      component: function (resolve) {
        require(['./components/order/detail.vue'], resolve)
      }
    },
    '/order': {
      component: function (resolve) {
        require(['./components/order/order-list.vue'], resolve)
      }
    },
    '/mine/:status': {
      component: function (resolve) {
        require(['./components/mine/income.vue'], resolve)
      }
    },
    '/mine': {
      component: function (resolve) {
        require(['./components/mine/index.vue'], resolve)
      }
    },
    '/signup': {
      component: function (resolve) {
        require(['./components/signup/signup.vue'], resolve)
      }
    },
    '/certification': {
      component: function (resolve) {
        require(['./components/signup/certification.vue'], resolve)
      }
    },
    '/task/history': {
      component: function (resolve) {
        require(['./components/task/history-task.vue'], resolve)
      }
    },
    '/city': {
      component: function (resolve) {
        require(['./components/mine/city.vue'],resolve)
      }
    },
    '/mine/service': {
      component: function (resolve) {
        require(['./components/mine/service.vue'],resolve)
      }
    },
    '/mine/rule': {
      component: function (resolve) {
        require(['./components/mine/rule.vue'],resolve)
      }
    },
    '/mine/help': {
      component: function (resolve) {
        require(['./components/mine/help.vue'],resolve)
      }
    },
    '/activity/share_page': {
      component: function (resolve) {
        require(['./components/activity/share_page.vue'],resolve)
      }
    }
})
// HOST = decodeURIComponent(HOST)
Vue.http.get("/weixins/weixin_jssign_package.json", {params: {url: HOST}}).then(function (o) {
  console.log(o.json())
  o = o.json()
  o['jsApiList'] = [
    'closeWindow',
    'chooseImage',
    'previewImage',
    'uploadImage',
    'onMenuShareTimeline',
    'onMenuShareAppMessage',
    'onMenuShareQQ',
    'onMenuShareQZone'
    // 'hideAllNonBaseMenuItem'
  ]
  // o.debug = true
  wx.config(o)
})
wx.ready(function(){
  // wx.hideAllNonBaseMenuItem()
  wx.onMenuShareAppMessage({
    title: '进货团,够胆你就来', // 分享标题
    desc: '进货团·招贤令', // 分享描述
    success: function () {
        // 用户确认分享后执行的回调函数
    },
    cancel: function () {
        // 用户取消分享后执行的回调函数
    }
  })
  // wx.error(function(res){
  // })
})
router.start(App, 'body')


