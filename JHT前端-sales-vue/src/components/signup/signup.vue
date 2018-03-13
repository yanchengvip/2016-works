<template>
  <page-header :config='headerConfig'></page-header>
  <main>
    <form>
      <fieldset>
        <div class="form-group">
          <label>手机号</label>
          <input type="tel" v-model="tel" placeholder="请输入手机号">
        </div>
        <div class="form-group">
          <label>验证码</label>
          <input type="tel" v-model="code" placeholder="请输入验证码">
          <a href="javascript:;" class="line-btn" @click="sendCode">{{ waiting ? wait +'s后重试':'获取验证码'}}</a>
        </div>
        <div class="form-group">
          <label>所在城市</label>
          <!-- <input type="tel" v-model="tel" placeholder="请选择所在城市"> -->
          <address :value.sync='value' id="address" :loading.sync='showLoading'></address>
        </div>
      </fieldset>
    </form>
    <div class="agreement">
      <input type="checkbox" v-model="checked" id="agreement"><label for="agreement">我已阅读并同意<span class="main-color">《法律声明》</span>和<span class="main-color">《隐私政策》</span>的全部内容</label>
    </div>
    <a href="javascript:;" class="btn" :class="{ active: formChecked }" @click="submitForm">立即注册</a>
  </main>
  <loading :show="showLoading" ></loading>
</template>

<script>
import Address from '../parts/address'
export default {
  data () {
    return {
      headerConfig: {
        title: '注册',
        back: true,
        positionAbsolute: /iphone/i.test(navigator.userAgent)
      },
      loading: false,
      tel: '',
      code: '',
      sending: false,
      waiting: false,
      wait: 60,
      checked: true,
      value: {
        provinceId: 0,
        cityId: 0,
        districtId: 0
      },
      showLoading: false,
      formChecked: false,
      wxCode: null
    }
  },
  components: {
    'address': Address
  },
  ready: function () {
    this.wxCode = this.$route.query.code
    let token = this.$route.query.remember_token
    if (token) {
        window.TOKEN = token
        localStorage.setItem('token', token)
    }
  },
  methods: {
    sendCode: function () {
      if (this.waiting || this.loading) {
        return
      }
      if (/^1\d{10}$/.test(this.tel)){
          this.loading = true
          Vue.http.post("/send_check_code", {'mobile': this.tel}).then((o)=> {
              o = o.json()
              this.loading = false
              if (o.status == 'ok') {
                this.waiting = true
                let id = setInterval(()=> {
                    if (this.wait > 0) {
                        this.wait -= 1
                    } else {
                        clearInterval(id)
                        this.waiting = false
                        this.wait = 60
                    }
                }, 1000)
              }
              alert(o.message)
          },() =>{
              this.loading = false
          })
      } else {
          alert('请输入正确的手机号')
      }
    },
    checkForm: function () {
      let addr = this.value
      if (this.tel && this.code && this.value.provinceId && this.value.cityId && this.checked) {
        this.formChecked = true
      } else {
        this.formChecked = false
      }
    },
    submitForm: function () {
      if (this.formChecked) {
        let data = {
          Mobile: this.tel,
          check_code: this.code,
          ProvinceID: this.value.provinceId,
          CityID: this.value.cityId,
          CountyID: this.value.districtId,
          code: this.wxCode
        }
        this.showLoading = true
        if (this.formChecked) {
          Vue.http.post('/signup', data).then((o) => {
            this.showLoading = false
            let res = o.json()
            if (res.status == 'ok') {
              alert('注册成功')
              this.$router.go({path: '/certification'})
            } else {
              alert(res.message)
            }
          })
        }
      } else {
        alert('请完成所有项目的填写')
      }

    }
  },
  watch: {
    'tel': function () {
      this.checkForm()
    },
    'code': function () {
      this.checkForm()
    },
    'checked': function () {
      this.checkForm()
    },
    'value.procinceId': function () {
      this.checkForm()
    },
    'value.cityId': function () {
      this.checkForm()
    },
    'value.districtId': function () {
      this.checkForm()
    }
  }
}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
main {
  background-color: $bg-color;
}
#address {
  height: 100%;
  line-height: 100%;
  position: absolute;
  left: 6.2rem;
  top: 0;
}
.agreement {
  margin-top: 1rem;
  font-size: 1rem;
  color: $text-color;
  text-align: center;
}
.btn {
  margin-top: 3.6rem;
}
</style>
