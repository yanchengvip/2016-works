<template>
  <header>
    <div class="top">
      <span>个人中心</span>
      <div class="region" v-link="{ path: '/city' }">{{ datas.cityName }}</div>
    </div>
    <div class="personal-info">
      <div class="avatar">
        <!-- <img src="../../assets/mine/head.png" alt=""> -->
        <img :src="i.user_logo">
        <span>{{ i.name }}</span>
      </div>
      <div class="qr" @click ="showQr=true"></div>
    </div>
  </header>
  <!-- 二维码 -->
  <div class="code-box" v-if="showQr" @click="showQr=false">
    <div class="layer"></div>
    <div class="code-info">
      <div class="avatar">
        <!-- <img src="../../assets/mine/head.png" alt=""> -->
        <img :src="i.user_logo">
        <span>{{ i.name }}</span>
        <span class="city">{{ datas.cityName }}</span>
      </div>
      <div class="qrcode">
        <img :src="i.qrcode_url">
        <span>扫一扫上面的二维码，绑定推广员</span>
      </div>
    </div>
  </div>
  <main>
    <div class="income pure-g">
      <a href="javascript:;" class="pure-u-1-2" v-link="{path: '/mine/yes'}">
        <div class="settled">¥{{ i.balanced }}</div>
        <div class="small" >已得收入</div>
      </a>
      <a href="javascript:;" class="pure-u-1-2" v-link="{path: '/mine/no'}">
        <div class="pending">¥{{ i.no_balanced }}</div>
        <div class="small">待结收入</div>
      </a>
    </div>
    <div class="use-help">
      <a v-link="{path: '/mine/help'}">
        <img src="../../assets/mine/help.png" alt="">
        <span>使用帮助</span>
      </a>
      <a v-link="{path: '/mine/rule'}">
        <img src="../../assets/mine/manual.png" alt="">
        <span>查看规则</span>
      </a>
      <a v-link="{path: '/mine/service'}">
        <img src="../../assets/mine/contact_service.png" alt="">
        <span>联系客服</span>
      </a>
    </div>
  </main>
  <city v-if="showCity"></city>
  <footer-nav></footer-nav>
  <loading :show="showLoading" ></loading>
</template>

<script>
import City from '../mine/city'

export default {
  data () {
    return {
      headerConfig: {
        tabs: [
          {
            name: '进行中',
            active: true
          }, {
            name: '已结束',
            active: false
          }
        ]
      },
      i: {},
      datas: {},
      showLoading: false,
      showQr: false,
      showCity: false
    }
  },
  components: {
    'city': City
  },
  ready: function () {
    this.showLoading = true
    Vue.http.get('/users/user_incoming.json').then((o)=>{
      this.showLoading = false
      this.i = o.json()
    })
    // 获取当前地址
    Vue.http.get('/users/user_address.json').then((o)=>{
      this.datas = o.json()
    })
    

  },
  methods: {
    goTo: function (id) {
      this.$router.go({
        path: '/task/'+id
      })
    }
  }
}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
html,
body {
    background: #F3F4F5;
}
header {
    position: relative;
    width: 100%;
    height: 14.1rem;
    overflow: hidden;
    background-image: url(../../assets/mine/bg_top.png);
    background-repeat: no-repeat;
    background-size: 100% 100%;
    .top {
        position: relative;
        width: 100%;
        height: 4rem;
        line-height: 4rem;
        overflow: hidden;
        text-align: center;
        color: #fff;
        span {
            display: inline-block;
            font-family: STHeiti;
            font-size: 2rem;
            font-weight: 600;
            color: #fff;
            line-height: 4rem;
        }
        .region {
            display: inline-block;
            /*width: 5rem;*/
            height: 1.6rem;
            line-height: 1.6rem;
            padding-left: 1.6rem;
            position: absolute;
            top: 50%;
            right: 1.5rem;
            margin-top: -0.8rem;
            font-size: 1rem;
            line-height: 1.8rem;
            background-image: url(../../assets/mine/loca.png);
            background-repeat: no-repeat;
            background-position: left center;
            background-size: auto 1.5rem; 
            overflow:hidden;
            text-overflow:ellipsis;
            white-space:nowrap;   
        }
    } 
    .personal-info {
        position: absolute;
        top: 50%;
        margin-top: -1.5rem;
        padding-left: 1.2rem;
        width: 100%;
        height: 6.4rem;
        .avatar {
            display: inline-block;
            height: 6.4rem;
            font-family: STXihei;
            font-size: 1.8rem;
            color: #fff;
            img {
                width: 5.7rem;
                height: 5.7rem;
                border-radius: 50%;
                border: .3rem solid rgba(255,255,255,.2);
                margin-right: .2rem;
                vertical-align: middle;
            }
        }
        .qr {
            position: absolute;
            top: 50%;
            margin-top: -1.3rem;
            right: 1.6rem;
            display: inline-block;
            width: 2.2rem;
            height: 2.2rem;
            background-image: url(../../assets/mine/qr_code.png);
            background-size: 100% 100%;
            background-repeat: no-repeat;
            background-position: center center;
        }
    }
}
.code-box {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    .layer {
        position: absolute;
        top: 0;
        left: 0;
        z-index: 19;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,.5);
    }
}
.code-info {
    width: 24.8rem;
    height: 37rem;
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 29;
    margin: auto;
    background-color: #fff;
    .avatar {
        position: relative;
        display: inline-block;
        height: 6.4rem;
        margin-left: 1.2rem;
        margin-top: 1.2rem;
        font-family: STXihei;
        font-size: 1.8rem;
        color: #000;
        img {
            width: 5.7rem;
            height: 5.7rem;
            border-radius: 50%;
            border: .3rem solid rgba(255,255,255,.2);
            margin-right: .2rem;
            vertical-align: middle;
        }
        .city {
            position: absolute;
            bottom: .5rem;
            left: 6.4rem;
            font-size: 1.1rem;
        }  
    }
    .qrcode {
        width: 20rem;
        height: 20rem;
        margin: 0 auto;
        margin-top: 1.4rem;
        text-align: center;
        span {
            font-family: STHeiti;
            font-size: 1.3rem;
            color: #9F9F9F;
            line-height: 3.9rem;
        }
    }
}
main {
    .income {
        width: 100%;
        height: 6.4rem;
        margin: 1.1rem 0;
        background: #fff;
        a {  
            height: 4rem;
            margin: 1.2rem 0;
            line-height: 2.3rem;
            font-family: PingFangSC-Regular;
            font-size: 1.4rem;
            color: #3C3C3C;
            text-align: center;
            .settled {
                font-family: Helvetica;
                font-size: 1.9rem;
                color: #6AB64F; 
            }
            .pending {
                font-family: Helvetica;
                font-size: 1.9rem;
                color: #F6B150;
            }
        }
        a:nth-of-type(1) {
            border-right: 1px solid #E0E0E0;
        }
    }
    .use-help {
        width: 100%;
        height: auto;
        margin: 0;
        padding: 0;
        a {
            display: inline-block;
            width: 100%;
            height: 4.4rem;
            padding-bottom: 1px;
            line-height: 4.4rem;
            background: #fff;
            img {
                margin-left: 1.5rem;
                width: 1.8rem;
                height: 1.8rem;
                vertical-align: middle;
            }
            span {
                display: inline-block;
                float: right;
                width: 27rem;
                height: 100%;
                font-family: STXihei;
                font-size: 1.5rem;
                color: #3C3C3C;
                text-indent: .3rem;
                background-image: url(../../assets/mine/right_arrow.png);
                background-repeat: no-repeat;
                background-position: 97% center;
                border-bottom: 1px solid #DFE0E2;
            }
        }
        a:last-of-type {
            span {
                border-bottom: 0;
            }
        }
    }
}
</style>
