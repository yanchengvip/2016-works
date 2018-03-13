<template>
    <main>
        <footer class="pure-g">
            <a class="pure-u-1-5" v-link="{path: '/task/my'}" :class='{active: this.$route.path.indexOf("/task/my") >= 0}'>
                <img src="../../assets/footer/1.svg">
                <img src="../../assets/footer/1b.svg">
                <div class="title">我的任务</div>
            </a>
            <a class="pure-u-1-5" v-link="{path: '/task/center'}" :class='{active: this.$route.path.indexOf("/task/center") >= 0}'>
                <img src="../../assets/footer/2.svg">
                <img src="../../assets/footer/2b.svg">
                <div class="title">任务中心</div>
            </a>
            <a class="pure-u-1-5" @click="show=true" class="code">
                <img src="../../assets/footer/plus.svg"><br>
                <div class="title">识别码</div>
                <label for="input"></label>
                <!-- <input type="url" id="input" v-model="number" @focus="" @blur=""> -->
            </a>
            <a class="pure-u-1-5" v-link="{path: '/order'}" :class='{active: this.$route.path.indexOf("/order") >= 0}'>
                <img src="../../assets/footer/3.svg">
                <img src="../../assets/footer/3b.svg">
                <div class="title">订单列表</div>
            </a>
            <a class="pure-u-1-5" v-link="{path: '/mine'}" :class='{active: this.$route.path.indexOf("/mine") >= 0}'>
                <img src="../../assets/footer/4.svg">
                <img src="../../assets/footer/4b.svg">
                <div class="title">个人中心</div>
            </a>
        </footer>
        <div v-show="show" class="shadow-box new">
            <div class="shadow"></div>
            <div class="code-box">
                <div class="title">提交识别码<i @click="closed"></i></div>
                <input type="url" placeholder="请输入识别码" autofocus="autofocus" v-model="code" @keyup.13="sendCode">
                <button @click="sendCode" >提交</button>
                <!-- <a @click='keyup' style="">提交</a> -->
            </div>
        </div>
        <div class="popup" v-show="showPopup">
            <img src="../../assets/footer/ok.png" alt="">
            <span>提交成功</span>
        </div>
        <confirm :show.sync="showConfirm" alert='true'>{{ message }}</confirm>
        <div class="failed-popup" v-if="showErrorPopup" :class="failedType">
          <div class="popup-wrapper">
            <div class="box">
              <div class="head"></div>
              <div class="content">
                <div class="title">{{ errorTitle }}</div>
                <div class="pic">
                  <img src="../../assets/footer/error.png" alt="" class="error">
                  <img src="../../assets/footer/unavailable.png" alt="" class="unavailable">
                  <img src="../../assets/footer/used.png" alt="" class="used">
                  <img src="../../assets/footer/instability.png" alt="" class="instability">
                </div>
                <div class="popup-btn">
                  <a href="javascript:;" class="btn" @click="reSubmit">重新提交</a>
                </div>
              </div>
            </div>
            <div class="close"></div>
          </div>
        </div>
        <loading :show="showLoading" ></loading>
    </main>

</template>

<script>
import Confirm from '../parts/confirm'
export default {
    props: {
        nav: {
            default: function () {
                return [
                        {
                            index: '1',
                            title: '我的任务',
                            path: '/task/my'
                        },
                        {
                            index: '2',
                            title: '任务中心',
                            path: '/task/center'
                        },
                        {
                            index: 'plus',
                            title: '识别码',
                            path: '/xxx'
                        },
                        {
                            index: '3',
                            title: '订单列表',
                            path: '/order'
                        },
                        {
                            index: '4',
                            title: '个人中心',
                            path: '/mine'
                        }
                    ]
            }
        }

    },
    data () {
        return{
            number: [],
            show: false,
            bgFlag: null,
            message: '',
            showLoading: false,
            showConfirm: false,
            showPopup: false,
            showErrorPopup: false,
            failedType: 'error',
            code: ''
        }
    },
    components: {
        'confirm': Confirm
    },
    computed: {
      'errorTitle': function () {
        return {
          'error': '识别码有误哦',
          'unavailable': '识别码已失效',
          'used': '识别码已被使用',
          'instability': '网络不稳定,请稍后再试'
        }[this.failedType]
      }
    },
    methods: {
      keyup: function () {
          this.sendCode()
      },
      $All: function(s) {
        return document.querySelectorAll(s)
      },
      closed: function(){
        this.code = ''
        this.show = false
      },
      toCancel: function (){
        this.showConfirm = false
        this.show= true
        $('#input').focus()
      },
      getFocus: function (e) {
        var ev = e || event;
         $('#input').focus()
         ev.stopPropagation();
      },
      popBox: function() {
        this.show = !this.show
        $('input[type="url"]').focus();
      },
      jump: function ($index) {
        let item = this.$All('input[type="url"]')[$index]
        if ($index <= 6 && item.nextElementSibling) {
            if (item.value.length == 1) {
                item.nextElementSibling.focus()
            }
        }
        if (item.value !== 'undefined') {
            this.number.push(item.value)
        }

      },
      del: function ($index) {
        let item = this.$All('input[type="url"]')[$index]
        if (item.previousElementSibling) {
            if (item.value.length == 0) {
                item.previousElementSibling.focus()
            }
        }
        if (item.value === 'undefined') {
            this.number.pop()
        }
      },
      sendCode: function(){
        console.log(this)
        // 提交验证码
        // if (this.showLoading) {
        //   return
        // }
        this.showLoading = true
        Vue.http.post('/users/bind_order.json', {rand_num: this.code}).then((o)=>{
            this.showLoading = false
            let data =  o.json()
            // data = {
            //   status: 60,
            //   message: "绑定失败!第三方提供的订单接口抛出异常!"
            // }
            if (data.status == 30) {
                this.showPopup = true
            } else {
                this.showError(data.status, data.message)           
            }
            setTimeout(() => {
                this.showPopup = false
                window.location.reload()
            },1500)

            this.show = false;
            this.code = ''
        })
      },
      showError: function (code, message) {
        if (code == 10) {
          this.failedType = 'error'
        } else if (code == 20) {
          this.failedType = 'unavailable'
        } else if (code == 40) {
          this.failedType = 'used'
        } else if (code == 70) {
          this.failedType = 'instability'
        } else {
          this.message = message
          this.showConfirm = true
          return
        }
        this.showErrorPopup = true
      },
      reSubmit: function () {
        this.showErrorPopup = false
        this.show = true
      }
    }
}
</script>



<style lang="scss" scoped>
@import '../../styles/variable.scss';
#input {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: transparent;
    border: 0;
    outline: 0;
    color: transparent;
}
label {
    display: block;
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: transparent;
    border: 0;
    outline: 0;
    color: transparent;
}
footer {
    overflow: hidden;
    height: 5.35rem;
    /*position: static;*/
    position: fixed;
    bottom: 0;
    left: 0;
    z-index: 10;
    width: 100%;
    background-image: url('../../assets/footer/bg.png');
    background-repeat: no-repeat;
    background-size: 100% 100%;
    background-position: 0 0;
    // display: flex;
    // display: -webkit-flex;
    // align-items: center;
    // -webkit-align-items: center;
    // justify-content: space-around;
    // -webkit-justify-content: space-around;
}
.popup {
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    margin: auto;
    width: 13.9rem;
    height: 11.9rem;
    background:rgba(0,0,0,0.75);
    border:1px solid #979797;
    border-radius:0.8rem;
    text-align: center;
    img {
        display: block;
        width: 4.5rem;
        height: 4.5rem;
        margin: 0 auto;
        margin-top: 2.5rem;
    }
    span {
        font-family:PingFangSC-Regular;
        font-size:1.8rem;
        color:#fff;
        line-height: 4.5rem;
    }
}
.code {
    // width: 3.5rem;
    // position: absolute;
    // left: 50%;
    // margin-left: -1.9rem;
    // top: .6rem;
}
.pure-u-1-5 {
    overflow: hidden;
    display: inline-block;
}
a {
    height: 5.35rem;
    display: block;
    text-align: center;
    position: relative;
    img {
        padding-top: .6rem;
        height: 3.3rem;
        width: auto;
        &:nth-child(2) {
            display: none;
        }
    }
    .title {
        position: absolute;
        bottom: .2rem;
        left: 0;
        width: 100%;
        text-align: center;
        font-size: .9rem;
        color: $text-color;
    }
    &.active {
        .title {
            color: $main-color;
        }
        img {
            height: 3.4rem;
            padding-top: .6rem;
            &:first-child {
                display: none;
            }
            &:nth-child(2) {
                display: inline-block;
            }
        }
    }
}
.shadow-box {
    position: fixed;
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;
    z-index: 100;
    background-color: rgba(0,0,0,.3);
}
.code-box{
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate3d(-50%,-50%,0);
    margin: auto;
    z-index: 101;
    width: 100%;
    text-align: center;
    background-color: #fff;
    .title{
        height: 4.5rem;
        line-height: 4.5rem;
        font-size: 1.6rem;
        color: #606060;
        border-bottom: 1px solid #e0e0e0;
        position: relative;
        i{
            width: 2.4rem;
            height: 2.4rem;
            background: url("../../assets/base/closed.svg") center center no-repeat;
            background-size: 80% 80%;
            position: absolute;
            right: 1rem;
            top: 1rem;
        }
    }
    button {
      display: inline-block;
      font-family:PingFangSC-Regular;
      /*width: 5rem;*/
      height: 3rem; 
      line-height: 3rem; 
      font-size: 1.4rem; 
      text-align: center; 
      margin: 0;
      padding: 0 1rem; 
      color: #FFF; 
      border: 0; 
      background-color:#17a2fd ; 
      border-radius: .4rem; 
    }
}
.number-box {
    height: 3.2rem;
    margin: 1.2rem 0;
    font-size: 0;
    input,
    span{
        font-size: 1.8rem;
        color: #404040;
        display: inline-block;
        width: 3.2rem;
        height: 3.2rem;
        padding: .2rem 0;
        line-height: 3.2rem;
        border: 1px solid #e0e0e0;
        border-radius: 0.4rem;
        margin: 0 .4rem;
        vertical-align: middle;
        text-align: center;
    }
}
.number{
    border-top: 1px solid #e0e0e0;
    font-size: 0;
    span{
        font-size: 1.8rem;
        color: #000;
        height: 4.7rem;
        line-height: 4.7rem;
        display: inline-block;
        width: 33.3%;
    }
    span:nth-child(3n-1){
        border-left: 1px solid #e0e0e0;
        border-right: 1px solid #e0e0e0;
        box-sizing: border-box;
    }
    .border{
        border-left: 1px solid #e0e0e0;
        border-right: 1px solid #e0e0e0;
        box-sizing: border-box;
    }
    .bg{
        background-color: #17A2FD;
    }
}
.failed-popup {
  z-index: 1000;
  position: fixed;
  background-color: rgba(0, 0, 0, .6);
  top: 0;
  left: 0;
  height: 100%;
  width: 100%;
  &.error {
    .head {
      background-color: #EC4D2D;
    },
   .title {
      color: #EC4D2D;
    }
    img.error {
      display: inline-block;
    }
  }
  &.unavailable {
    .head {
      background-color: #909090;
    }
   .title {
      color: #909090;
    }
    img.unavailable {
      display: inline-block;
    }
  }
  /*new add style*/
  &.instability {
    .head {
      background-color: #FF8730;
    }
   .title {
      color: #FF8730;
    }
    img.instability {
      display: inline-block;
    }
  }
  &.used {
    .head {
      background-color: #17A2FD;
    }
   .title {
      color: #17A2FD;
    }
    img.used {
      display: inline-block;
    }
  }
}
.popup-wrapper {
  position: absolute;
  width: 22rem;
  height: 31.4rem;
  left: 50%;
  top: 50%;
  margin-left: -11rem;
  margin-top: -15.7rem;
  .head {
    height: .8rem;
    border-top-left-radius: .4rem;
    border-top-right-radius: .4rem;
    background-color: #ec4d2d;
  }
  .content {
    background-color: #fff;
    padding-top: 2rem;
    padding-bottom: 1.65rem;
  }
  .title {
    text-align: center;
    font-size: 1.6rem;
  }
  .pic {
    margin-top: 1rem;
    text-align: center;
    img {
      display: none;
      width: 13rem;
      height: auto;
    }
  }
  .popup-btn {
    margin-top: 2.15rem;
    text-align: center;
    a {
      margin: 0;
      width: 18rem;
      display: inline-block;
      color: #17a2fd;
      border: 1px solid #17a2fd;
      background-color: #FFF;
      border-radius: .4rem;
    }
  }
}
.shadow-box.new {
  .code-box {
    width: 90%;
  }
  input {
    margin: 1rem auto;
    height: 3rem;
    font-size: 1.6rem;
    text-align: center;
    color: $text-color;
    border: 1px solid #17A2FD;
    border-radius: .4rem;
  }
}
</style>
