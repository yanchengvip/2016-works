<template>
  <page-header :config='headerConfig'></page-header>
  <main>
    <form>
      <fieldset>
        <div class="form-group">
          <label>真实姓名</label>
          <input type="text" v-model="name" placeholder="请输入您的真实姓名">
        </div>
        <div class="form-group">
          <label>身份证号</label>
          <input type="text" v-model="IDcardNo" placeholder="请输入您的身份证号">
        </div>
        <div class="form-group clearfix" id="upload">
          <div class="file-box">
            <div class="img-wrapper">
              <img src="../../assets/signup/id.png" id="img-id" @click="uploadImg('id')">
            </div>
          </div>
          <p class="desc">
            请上传原始比例的身份证正面照片，请勿裁剪涂改，保持身份证信息清晰，否则无法通过审核
          </p>
        </div>
        <!-- 银行相关 -->
        <div class="form-group">
          <label>银行卡号</label>
          <input type="text" v-model="bankCardNo" placeholder="请输入您的银行卡号">
        </div>
        <div class="form-group">
          <label>开户银行</label>
          <select v-model="bankId" id="bankAccount" class="select-all" :class='{ selected: bankId}'>
            <option value=0>请选择开户银行</option>
            <option v-bind:value="bank.ID" v-for="bank in bankList">{{ bank['Name'] }}</option>
          </select>
        </div>
        <div class="form-group clearfix">
          <label>发行城市</label>
          <div class="select_group">
            <select v-model="provinceId" id="bankProvince" class="select-all" :class='{ selected: provinceId}'>
              <option value=0>请选择开户省份</option>
              <option v-for="province in provinceList" value="{{ province.ID }}">{{ province.Name }}</option>
            </select>
            <select v-model="cityId" id="bankCity" class="select-all" :class='{ selected: cityId}'>
              <option value=0>请选择开户城市</option>
              <option v-for="city in cityList" value="{{ city.ID }}">{{ city.Name }}</option>
            </select>
          </div>
          </div>

        <div class="form-group">
          <label>选择支行</label>
          <select v-model="branchBankId" id="branchBank" class="select-all" :class='{ selected: branchBankId}'>
            <option value=0>请选择开户支行</option>
            <option v-for="branchBank in branchBankList" value="{{ branchBank.Name }}">{{ trimCompany(branchBank.Name) }}</option>
          </select>
        </div>
        <!-- 银行卡上传 -->
        <div class="form-group clearfix" id="upload">
          <div class="file-box">
            <div class="img-wrapper">
              <img src="../../assets/signup/bank.png" id="img-bank" @click="uploadImg('bank')">
            </div>
          </div>
          <p class="desc">
            请上传原始比例的银行卡正面照片，请勿裁剪涂改，保持身份证信息清晰，否则无法通过审核
          </p>
        </div>
      </fieldset>
    </form>
    <a class="btn" :class="{ active: formChecked }" @click="submitForm">认证</a>
  </main>
  <loading :show="showLoading" ></loading>
</template>

<script>
export default {
  data () {
    return {
      headerConfig: {
        title: '实名认证',
        back: false,
        positionAbsolute: /iphone/i.test(navigator.userAgent)
      },
      styleObject: {
        width:'15rem',
        height:'9.4rem'
      },
      name: '',
      IDcardNo: '',
      bankCardNo: '',

      value: [

      ],
      imgChoosed: {
        id: null,
        bank: null
      },
      reSubmit: false,
      loadCallback: null,
      wxCode: null,
      bankId: 0,
      provinceId: 0,
      cityId: 0,
      branchBankId: 0,
      bankList: [],
      provinceList: [],
      cityList: [],
      branchBankList: [],
      issuingBank: '',
      branch: '',
      showLoading: false,
      formChecked: false
    }
  },
  ready: function () {
    // window.saveToken()
    this.loadBanks(() => {
      this.checkResubmit()
    })
  },
  methods: {
    uploadImg: function(arg) {
      wx.ready( () => {
        wx.chooseImage({
          count: 1,
          sizeType: ['original', 'compressed'],
          sourceType: ['album', 'camera'],
          success: (res) => {
            let localIds = res.localIds
            $('#img-'+arg).src = localIds
            wx.uploadImage({
              localId: localIds[0],
              isShowProgressTips: 1,
              success: (res) => {
                  this.imgChoosed[arg] = res.serverId
                  this.checkForm()
                  // this.alert(res.serverId)
              }
            })
          }
        })
      })
      // wx.chooseImage({
      //   count: 1,
      //   sizeType: ['original', 'compressed'],
      //   sourceType: ['album', 'camera'],
      //   success: (res)=> {
      //     let localIds = res.localIds
      //     $('#img-'+arg).src = localIds
      //     wx.uploadImage({
      //         localId: localIds[0],
      //         isShowProgressTips: 1,
      //         success: (res) => {
      //             this.imgChoosed[arg] = res.serverId
      //             this.checkForm()
      //             // this.alert(res.serverId)
      //       }
      //     })
      //   }
      // })
    },
    $All: function (obj) {
      return document.querySelectorAll(obj)
    },
    selectItem: function (item, varName, value, callback) {
      if (!value) {
        return
      }
      let trueValue = null
      if (item == 'branchBank') {
          trueValue = value
      } else {
          let options = document.querySelectorAll('#'+item+'>option')
          for (var i = options.length - 1; i >= 0; i--) {
              let option = options[i]
              if (option.innerText == value) {
                  trueValue = option.value
                  break
              }
          }
      }
      this.loadCallback = callback
      this[varName] = trueValue
    },
    loadBanks: function (callback) {
      Vue.http.get('/bank_infoes/bank_query.json').then((o)=>{
        this.bankList = o.json()
        callback && callback()
        this.showLoading = false
      })
    },
    loadSubData: function (id, callback) {
      this.showLoading = true
      let data = {
        params: {
          id: id
        }
      }
      Vue.http.get('/bank_infoes/bank_branch.json', data).then((o)=>{
          callback(o.json())
          this.showLoading = false
      })
    },
    checkForm: function () {
      if (this.name && this.IDcardNo && this.bankCardNo && this.branchBankId != 0 && _.every(_.values(this.imgChoosed))) {
        this.formChecked = true
      } else {
        this.formChecked = false
      }
    },
    submitForm: function () {
      // 输入信息完整时 执行
      if (this.formChecked) {
        if ( !(/^([\u4E00-\u9FA5]+|[a-zA-Z]+)$/.test(this.name)) ) {
          return alert('请输入真实姓名')
        }
        if ( !(/(^\d{15}$)|(^\d{17}([0-9]|X|x)$)/.test(this.IDcardNo)) ) {
          return alert('身份证号码格式不正确')
        }
        if ( !(/^(\d{16,19})$/.test(this.bankCardNo)) ) {
          return alert('银行卡号格式不正确')
        }
        if (!_.every(_.values(this.imgChoosed))) {
          return alert('请添加证件照片')
        }
        let user = {
            "Name": this.name,
            "IDcardNo": this.IDcardNo,
            "BankCardNo": this.bankCardNo,
            "IDcardPic": this.imgChoosed.id,
            "BandCardPic": this.imgChoosed.bank,
            "BankAccount": $('#bankAccount>option:checked').text,
            "BankProvince": $('#bankProvince>option:checked').text,
            "BankCity": $('#bankCity>option:checked').text,
            "BankBranch": this.branchBankId
        }
        this.showLoading = true
        Vue.http.post('/user_verify', user).then((o)=>{
          this.showLoading = false
          alert(o.json().message)
          if (o.json().status == 'ok') {
            wx.closeWindow()
          }
        },
        (o)=>{
          alert('出错了..')
        })
      } else {
        alert('请完成所有项目的填写')
      }
    },
    trimCompany: function (s) {
        let index =  s.indexOf('公司')
        if (index > 0) {
            return s.slice(index+2)
        } else {
            return s
        }
    },
    checkResubmit: function() {
        let selectItem = this.selectItem
        this.loading = true
        Vue.http.get('/users/user_info.json').then((o)=> {
          this.loading = false
          o = o.json()
          if (o.status == 'ok') {
            this.reSubmit = true
            this.name = o.name
            this.IDcardNo = o.IDcardNo
            this.bankCardNo = o.bankCardNo
            setTimeout(()=>{
                if (o.BandCardPic) {
                    $('#img-bank').src = o.BandCardPic
                    this.imgChoosed.bank = o.BandCardPic
                }
                if (o.IDcardPic) {
                    $('#img-id').src = o.IDcardPic
                    this.imgChoosed.id = o.IDcardPic
                }
                selectItem('bankAccount', 'bankId', o.BankAccount, ()=> {
                    selectItem('bankProvince', 'provinceId', o.BankProvince, ()=> {
                        selectItem('bankCity', 'cityId', o.BankCity, ()=> {
                            selectItem('branchBank', 'branchBankId', o.BankBranch)
                        })
                    })
                })
            })
          }
        })
    },
  },
  watch: {
    'name': function () {
      this.checkForm()
    },
    'IDcardNo': function () {
      this.checkForm()
    },
    'bankCardNo': function () {
      this.checkForm()
    },
    'bankId': function (newVal,oldVal) {
      this.loadSubData(newVal, (o) => {
          this.provinceList = o
          this.provinceId = 0
          setTimeout(() => {
              this.loadCallback && this.loadCallback()
          })
      })
      if (newVal!=0) {
          _.forEach(this.$All(".select-all"),function(value){
            value.classList.remove('red')
          })
          $("#bankProvince").classList.add('red')
      }
    },
    'provinceId': function (newVal,oldVal) {
      this.loadSubData(newVal, (o) => {
          this.cityList = o
          this.cityId = 0
          setTimeout(() => {
              this.loadCallback && this.loadCallback()
          })
      })
      if (newVal!=0) {
          _.forEach(this.$All(".select-all"),function(value){
            value.classList.remove('red')
          })
          $("#bankCity").classList.add('red')
      }
    },
    'cityId': function (newVal,oldVal) {
      this.loadSubData(newVal, (o) => {
            this.branchBankList = o
            this.branchBankId = 0
            setTimeout(() => {
                this.loadCallback && this.loadCallback()
            })
        })
      if (newVal!=0) {
          _.forEach(this.$All(".select-all"),function(value){
            value.classList.remove('red')
          })
          $("#branchBank").classList.add('red')
      }
    },
    'branchBankId': function (newVal, oldVal) {
      this.checkForm()
      if (newVal!=0) {
          _.forEach(this.$All(".select-all"),function(value){
            value.classList.remove('red')
          })
      }
    }
  }

}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
main {
  background-color: $bg-color;
  padding-bottom: 4rem;
}
#bankProvince,
#bankCity {
  /*max-width: 50%;*/
  width: auto;
}
.select_group {
  margin-left: 6.2rem;
  display: -webkit-box;
  display: box;
  select {
    width: 100%;
    -webkit-box-flex: 1;
       -moz-box-flex: 1;
        -ms-box-flex: 1;
            box-flex: 1;
    margin-right: 1rem;
  }
}
select {
    color: $light-text-color;
    width: calc(100% - 6.3rem);
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
    display: inline-block;
    font-size: 1.2rem;
    margin-bottom: -1.8rem;
    background-color: transparent;
    option {
        white-space: pre;
        min-height: 1.2em;
        padding: 0px 2px 1px;
        color: $text-color;
    }
    &.selected {
        color: $text-color;
    }
}
#upload {
    position: relative;
   /* width: 100%;*/
    height: 12rem;
    padding: 1.2rem 0;
      #img-id ,
      #img-bank {
        position: absolute;
        top: -2px;
        left: -2px;
        width: 14.8rem;
        height: 9.2rem;
        border: 2px solid #fff;
        z-index: 1;
      }
      .layer {
        position: absolute;
        top: 0;
        left: 0;
        z-index: 2;
        width: calc(100% + 2px);
        height: calc(100% + 2px);
        background: rgba(0,0,0,.4);
      }
      .file-box {
          float: left;
          position: relative;
          width:14.8rem;
          height:9.2rem;
          margin-right: 1rem;
          text-align: center;
          .file {
            width: 100%;
            height: 100%;
            position: absolute;
            z-index: 3;
          }
          .icon {
              width: 3.2rem;
              height: 3.2rem;
              position: absolute;
              top: 2rem;
              left: 50%;
              transform: translateX(-50%);
          }
          span {
              font-family:PingFangSC-Regular;
              display: block;
              margin-top: 5rem;
              font-size:1.4rem;
              color:$light-text-color;
          }
      }
      p {
        font-family:STXihei;
          margin-left: 15.8rem;
          max-width: 20rem;
          height: auto;
          font-family:STXihei;
          font-size:1.1rem;
          line-height: 1.4;
          color:$main-color;
      }
}
.btn {
    margin-top: 2rem;
}
.img-wrapper {
  img {
    border:2px dashed $line-color;
    width: 15rem;
    height: 9.4rem;
  }
}
select.red {
    border: 1px solid red;
}
</style>
