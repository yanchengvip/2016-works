<!-- 订单详情页 -->
<template>
<page-header :config='headerConfig'></page-header>
<main class="" id="">
  <div class="order-box">
    <ul class="order-list">
      <li v-for="(index,orderItem) in order.order_history" class="bj{{index}}">
          <h2>{{orderItem.order_status}}<i v-if="returnGoods(orderItem)">有退货</i><span>{{orderItem.record_time}}</span></h2>
          <div v-if="orderItem.order_status_num == 1" class="list-item">
            <p>订单号:{{order.order_code}}</p>
            <p>收件人:{{order.ship_name}}&nbsp;&nbsp;&nbsp;<span>{{order.ship_tel}}</span></p>
            <p>订单金额:¥{{order.order_money}}</p>
          </div>
          <!-- 发货 -->
           <div v-if="orderItem.order_status_num == 3" class="list-item">
            <p>货物正由司机 {{ order.driver_name }} 配送</p>
            <p>联系电话：{{ order.driver_mobile }} </p>
          </div>
          <!-- 支付 -->
          <div v-if="orderItem.order_status_num == 5" class="list-item">
            <p>{{ order.receive_price_type }} </p>
          </div>
          <!-- 完成 -->
          <div v-if="orderItem.order_status_num == 8" class="list-item">
            <!-- <p v-if="orderItem.is_have_return">有退货</p>
            <p v-if="!orderItem.is_have_return">无退货</p>
            <p v-else>订单完成</p> -->
          </div>
          <!-- 退款 -->
         <!--  <div v-else class="list-item">
            <template v-if="orderItem.return_order_info">
              <p>退款金额:¥{{orderItem.return_order_info.return_money}}</p>
              <p>退款时间:{{orderItem.return_order_info.record_time}}</p>
            </template>
            <template v-else>
              <p></p>
            </template>
          </div> -->
      </li>
    </ul>
    <div class="order-task">
      <h3 class="title"><span>匹配任务</span></h3>
      <ul class="task-list">
        <li v-for="item in order.order_tasks" @click='goTo(item.id)'>
            <div class="task-img">
              <img :src="item.task_logo" alt="">
            </div>
            <div class="task-text">
              <p class="task-title">{{item.title}}</p>
              <p class="task-time" >
                <span v-text="item.begin_time | substr"></span> -
                <span v-text="item.end_time | substr"></span>
              </p>
            </div>
        </li >
      </ul>
    </div>
  </div>
</main>
</template>

<script>
export default {
  data () {
    return {
      headerConfig: {
        title: "订单详情",
        back: true,
        fix: true
      },
      order: {},
      showLoading: false
    }
  },
  methods: {
    goTo: function(id) {
      this.$router.go({
        path: '/task/center/' + id
      })
    },
    returnGoods: function(item) {
      return _.isObject(item.return_order_info) && _.values(item.return_order_info).length != 0
    }
  },
  ready: function () {
    this.showLoading = true
    let data = {
      params: {
        user_order_id: this.$route.params.id
      }
    }
    Vue.http.get('/user_orders/order_details.json', data).then((o)=>{
      this.order = o.json().data
      this.showLoading = false
      this.order.order_history = this.order.order_history.reverse()
    })
  }
}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
main{
  min-height: 100%;
  // height: 100%;
  background-color: #fff;
  padding: 0 1.2rem;
  @at-root .order-list{
    padding-left: 2.6rem;
    li{
      padding-bottom: 1.6rem;
      position: relative;
      &::before,
      &::after{
        content: "";
        position: absolute;
      }
      &::after{
        width: 2rem;
        height: 2rem;
        left: -2.75rem;
        top: 0.6rem;
        background-position: center center;
        background-size: 100% 100%;
        background-repeat: no-repeat;

      }
      &::before{
        width: 0.1rem;
        height: 100%;
        background-color: #17A2FD;
        left: -1.8rem;
        top: 1.6rem;
      }
    }
    .bj0{
      &::after{
        background-image: url("../../../src/assets/order/order-submit.svg");
      }
    }
    .bj1{
      &::after{
        background-image: url("../../../src/assets/order/order-send.svg");
      }
    }
    .bj2{
      &::after{
        background-image: url("../../../src/assets/order/order-pay.svg");
      }
    }
    .bj3{
      &::after{
        background-image: url("../../../src/assets/order/order-finish.svg");
      }
    }
    li:last-child{
      &::before{
        display: none;
      }
    }
    h2{
      font-size: 1.4rem;
      line-height: 3.2rem;
      color: #404040;
      span{
        float: right;
        font-size: 1.1rem;
        color: #909090;
      }
      i{
        font-size: 1rem;
        color: #17A2FD;
        padding-left: 1rem;
      }
    }
    .list-item{
      padding: 0.5rem 1.2rem;
      background-color: #F8FBFD;
      font-size: 1.2rem;
      line-height: 2.3rem;
      color: #606060;
    }
  }
  @at-root .order-task{
    h3{
      border-top: 1px solid #606060;
      text-align: center;
      margin-bottom: 0.8rem;
      &::before{
        content: "";
        display: table;
      }
      span{
        display: block;
        width: 9.2rem;
        background-color: #fff;
        font-size: 1.3rem;
        color: #606060;
        height: 2rem;
        line-height: 2rem;
        margin: 0 auto;
        margin-top: -1rem;
      }
    }
    .task-img{
      float: left;
      width: 3.6rem;
      height: 3.6rem;
      border-radius: 50%;
      overflow: hidden;
      border: 1px solid #979797;
      img{
        width: 100%;
        height: 100%;
        vertical-align: top;
      }
    }
    .task-text{
      margin-left: 4.2rem;
      height: 4.5rem;
      border-bottom: 1px solid #e0e0e0;
      margin-bottom: 0.8rem;
    }
    .task-title{
      font-size: 1.2rem;
      color: #606060;
      line-height: 2.3rem;
    }
    .task-time{
      font-size: 1rem;
      color: #909090;
      line-height: 1.5rem;
    }
  }
}
.blueText {
  font-family:PingFangSC-Regular;
  font-size:1.1rem;
  color:#17a2fd;
}
h2,h3,p,ul{
  margin: 0;
  padding: 0;
}
i{
  font-style: normal;
}
ul{
  list-style: none;
}
</style>
