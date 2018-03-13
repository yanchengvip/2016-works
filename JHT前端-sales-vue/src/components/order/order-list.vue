<template>
  <header class="fixed">
    <div class="header-wrapper false" v-if="!showSearch">
      <img src="../../assets/order/search.svg" class="search" @click="showSearch=!showSearch">
      <img src="../../assets/order/calendar.svg" class="calendar" @click="showCalendar=true">
      <a class="text" href="javascript:;" @click="showSearch=!showSearch">{{ this.s ? this.s : '输入订单号、手机号查询'}}</a>
    </div>
    <div class="header-wrapper true" v-if="showSearch">
      <a href="javascript:;" id="back" @click="showSearch=false">
        <i class="icon">&#xe604;</i>
        <!-- <img src="../../assets/base/back.svg"> -->
      </a>
      <input class="reset" type="tel" placeholder="请输入订单号、手机号查询" autofocus="true" v-model="s" @keyup.enter="doSearch">
      <a href="javascript:;" class="search-btn" @click="doSearch">搜索</a>
    </div>
    <div class="header-wrapper true" v-if="dateConfig.show" :class="{ show: dateConfig.show }" >
      <a id="back" @click="dateConfig.show = false">
        <i class="icon">&#xe604;</i>
       <!--  <img src="../../assets/base/back.svg"> -->
      </a>
      <span>{{ showBegin }} 至 {{ showEnd }}</span>
      <img src="../../assets/calendar/arrow.png" alt="" @click="showCalendar=true">
    </div>
  </header>
  <main>
    <div id="wrapper" class="content-box" v-infinite-scroll="getList()" infinite-scroll-disabled="busy" infinite-scroll-distance="0" >
      <div v-if="orders == 0 && onOff == 0">
          <div class="no-order">
            <div class="box">
              <img src="../../assets/order/no-order.png" alt="">
            </div>
            <span>暂无订单，添加识别码试试</span>
          </div>
      </div>
      <div v-if="orders == 0 && onOff == 1">
          <div class="no-order">
            <div class="box">
              <img src="../../assets/order/not-find.png" alt="">
            </div>
            <span>没有查到 {{ s || '该时段内'}} 订单</span>
          </div>
      </div>
      <div class="order-item" v-for="order in orders" @click="goTo(order.user_order_id)">
        <div class="wrapper">
          <div class="head">
            <div class="left">
              {{ extractDate(order) }}
            </div>
            <div class="right">
              任务＋{{ order.tasks_num }}
            </div>
          </div>
          <div class="bottom">
            <div class="status" :class='getStatusClass(order.order_status)'>
              {{ getStatus(order.order_status) }}
            </div>
            <div class="order-num">订单号：{{ order.order_code }}</div>
            <div class="order-money">订单金额：<span class="money">¥{{ order.order_money }}</span></div>
          </div>
        </div>
      </div>

    </div>
  </main>
  <loading :show="showLoading" ></loading>
  <calendar :date-begin.sync="dateBegin" :date-end.sync="dateEnd" :show-switch.sync="showCalendar"></calendar>
  <footer-nav></footer-nav>
</template>

<script>
import Calendar from "../parts/calendar.vue"

export default {
  data () {
    return {
      showLoading: false,
      dateBegin: null,
      dateEnd: null,
      showCalendar: false,
      showSearch: false,
      orders: [],
      s: '',
      onOff: 0,
      showBegin: '',
      showEnd: '',
      hasMore: true,
      busy: false,
      num: 1,
      per_page: 4,
      dateConfig: {
        show: false,
        link: '/#!/order'
      }
    }
  },
  components: {
    'calendar': Calendar
  },
  methods: {
    goTo: function (id) {
      this.$router.go({
        path: '/order/'+id
      })
    },
    fetchData: function () {
      let data = {
        page: 1,
        per_page: this.per_page
      }
      if (this.s) {
        if (/^\d{11}$/.test(this.s)) {
          data['ship_tel'] = this.s
        } else {
          data['order_code'] = this.s
        }
      }
      if (this.dateBegin && this.dateEnd) {
        this.showBegin = this.dateBegin.join('-');
        this.showEnd = this.dateEnd.join('-');
        data['start_time'] = this.dateBegin.join('-')
        data['end_time'] = this.dateEnd.join('-')
        this.dateConfig.show = true;
      }
      this.showLoading = true
      Vue.http.get('/user_orders/user_order_list.json', {params: data}).then((o)=>{
        this.orders = o.json().data
        this.showLoading = false
      })
    },
    extractDate: function (order) {
      return _.first(order.order_history).record_time
    },
    getStatus: function (s) {
      return {
        '-2' : "已完成",
        '-1' : "已完成",
        1 : "待发货",
        3 : "待支付",
        5 : "已完成",
        8 : "已完成"
      }[s]
    },
    getStatusClass: function (s) {
      return {
        /*
        -2 订单退货  显示有退货标识
        -1 订单取消  点进去不应该没数据 应该提示订单已经取消了
        1  订单提交  
        3  货物已发出
        5  支付成功
        8  订单完成
        代发货：1  => s1
        已支付：3  => s2
        已完成：5 8 -1 -2  => s3
        */ 
        '-2': 's3',
        '-1': 's3',
        1 : "s1",
        3 : "s2",
        5 : "s3",
        8 : "s3",
      }[s]
    },
    doSearch: function () {
      if (this.s || (this.dateBegin && this.dateEnd)) {
        this.fetchData()
      }
      this.onOff = 1
      setTimeout(()=>{
        this.dateBegin = null
        this.dateEnd = null
        this.showSearch = false
      })
    },
    getList: function(){
      // this.busy = true
      if(this.hasMore){
        this.num += 1
        let data = {
          params: {
            page: this.num,
            per_page: this.per_page
          }
        }
        Vue.http.get('/user_orders/user_order_list.json',data).then((o)=>{
          if(o.json().data.length == 0){
            this.hasMore = false
            this.busy = true
          }
          this.orders = this.orders.concat(o.json().data)
        })
      }
    }
  },
  ready: function (){
    this.fetchData()
  },
  watch: {
    'showCalendar': function (newVal, oldVal) {
      if (!newVal) {
        this.doSearch()
      }
    },
    'showSearch': function (newVal, oldVal) {
      if (newVal) {
        let s = this.s
        this.s = ''
        if (s) {
          this.fetchData()
        }
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
header {
  height: 4rem;
  line-height: 4rem;
  font-size: 1.5rem;
  position: relative;
  width: 100%;
  z-index: 100;
  .header-wrapper {
    width: 100%;
    height: 100%;
    position: relative;
    &.false {
      background-color: $main-color;
    }
    &.true {
      background-color: #fff;
    }
    &.date {
      display: none;
    }
  }
  &.fixed {
      position: fixed;
      top: 0;
      left: 0;
  }
}
.show {
  position: absolute !important;
  top: 0;
  z-index: 10;
  display: block;
  text-align: center;
  span {
    display: inline-block;
    font-family:PingFangSC-Regular;
    font-size: 1.2rem;
    color:#404040;
  }
  img {
    display: inline-block;
    width: 1.2rem;
    height: auto;
  }
}
main {
  padding-bottom: 5.5rem;
}
img.search,
.text {
  width: 26rem;
  height: auto;
  position: absolute;
  top: .6rem;
  left: 1.2rem;
}
img.calendar {
  position: absolute;
  height: 2.4rem;
  width: auto;
  right: 1.2rem;
  top: .8rem;
}
.text {
  width: 26rem;
  height: 2.9rem;
  font-size: 1.3rem;
  color: #c0c0c0;
  text-align: center;
  line-height: 3.1rem;
}
#back {
  display: block;
  width: 2rem;
  height: 100%;
  position: absolute;
  top: 0;
  left: 1rem;
  i {
    font-size: 2.5rem;
    color: $main-color;
  }
  img {
    display: inline-block;
    vertical-align: middle;
  }
}
.search-btn {
  font-size: 1.5rem;
  color: $main-color;
  display: block;
  position: absolute;
  right: 1.2rem;
  top: .5rem;
  height: 3rem;
  line-height: 3rem;
}
.no-order {
  width: 28rem;
  margin: 0 auto;
  margin-top: 14rem;
  text-align: center;
  .box {
    width: 17rem;
    height: 9.3rem;
    margin: 0 auto;
    img {
      width: 100%;
      height: 100%;
    }
  }
  span {
    line-height: 4.3rem;
    font-family:PingFangSC-Regular;
    font-size:1.3rem;
    color:#909090;
  }
}
.order-item {
  padding: 0 1.2rem;
  background-color: #fff;
  margin-bottom: 1.2rem;
  .wrapper {

  }
  .head {
    height: 3.2rem;
    font-size: 1.2rem;
    border-bottom: 1px solid $line-color;
  }
  .left {
    color: $text-color;
    line-height: 3.2rem;
    height: 3.2rem;
    float: left;
  }
  .right {
    line-height: 3.2rem;
    height: 3.2rem;
    float: right;
    color: $main-color;
  }
  .bottom {
    position: relative;
    height: 6rem;
    padding-left: 5.2rem;
  }
  .status {
    background-color: #AC4DFF;
    height: 4.4rem;
    width: 4.4rem;
    border-radius: 50%;
    line-height: 4.4rem;
    text-align: center;
    color: #fff;
    font-size: 1.2rem;
    position: absolute;
    left: 0;
    top: .8rem;
    &.s1 {
      background-color: #ac4dff;
    }
    &.s2 {
      background-color: #f95f6f;
    }
    &.s3 {
      background-color: #65c6b4
    }
  }
  .order-num, .order-money {
    height: 3rem;
    line-height: 3rem;
    color: $text-color;
    font-size: 1.2rem;
  }
  .money {
    color: #ec4d2d;
  }
}
input.reset {
  background: url('../../assets/base/search-ico.svg') 0.725rem center no-repeat #F3F4F5;
  background-size: 1.45rem auto;
  border: 1px solid #c0c0c0;
  width: 22.6rem;
  height: 2.9rem;
  left: 4rem;
  border-radius: .5rem;
  font-size: 1.3rem;
  position: relative;
  padding-left: 2.54rem;
  box-sizing: border-box;
  color: $title-color;
}
</style>
