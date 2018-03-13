<!-- 任务详情页 -->
<template>
<page-header :config='headerConfig'></page-header>
<main class="" id="">
  <div class="content-box" :class="{ fail: notStandard }">
    <div class="content-item">
      <div class="region-limit" v-show="task.belong_city">仅限{{ task.belong_city }}使用</div>
      <div class="img-box">
        <img :src="task.task_logo" alt="">
      </div>
      <span class="state-tip" :class='getStatusClass(task.is_start)' >{{ getStatus(task.is_start) }}</span>
      <p class="title">{{task.title}}</p>
      <p class="time" :class="{ no: task.is_start == 2}">{{ (task.begin_time || '').slice(0,10) }}&nbsp;- &nbsp;{{ (task.end_time || '').slice(0,10) }}</p>
    </div>
<!-- 任务详情 -->
    <div class="cont-list">
      <template v-if="task.task_type == 0">
        <template v-if="task.current_step == 0">
          <div class="list-item complete">
            <span class="index-num index-now"></span>
            <div class="list-text now-text">
              <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
              <!-- <img src="../../../src/assets/Taskdetails/no.svg" alt=""> -->
            </div>
          </div>
        </template>
        <template v-for="step in task.task_steps">
          <div  class="list-item" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成订单，奖励订单总额{{(step.reward *100).toFixed(2)}}%</span>
            </div>
          </div>
          <template v-if="task.current_step == step.step">
            <div class="list-item complete ">
              <span class="index-num index-now"></span>
              <div class="list-text now-text">
                <span>已完成¥{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
                <img src="../../../src/assets/Taskdetails/ok.svg" alt="">
              </div>
            </div>
          </template>
        </template>
      </template>
      <template v-if="task.task_type == 1">
        <template v-if="task.current_step == 0">
          <div class="list-item complete">
            <span class="index-num index-now"></span>
            <div class="list-text now-text">
              <span>已完成¥{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
            </div>
          </div>
        </template>
        <template v-for="step in task.task_steps">
          <div  class="list-item" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成¥{{step.amount}}，奖励¥{{step.reward}}</span>
            </div>
          </div>
          <template v-if="task.current_step == step.step">
            <div class="list-item complete">
              <span class="index-num index-now"></span>
              <div class="list-text now-text">
                <span>已完成¥{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
                <img src="../../../src/assets/Taskdetails/ok.svg" alt="">
              </div>
            </div>
          </template>
        </template>
      </template>
      <template v-if="task.task_type == 2">
        <template v-if="task.current_step == 0">
          <div class="list-item complete">
            <span class="index-num index-now"></span>
            <div class="list-text now-text">
              <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
            </div>
          </div>
        </template>
        <template v-for="step in task.task_steps">
          <div  class="list-item" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成{{step.amount}}，奖励¥{{step.reward}}</span>
            </div>
          </div>
          <template v-if="task.current_step == step.step">
            <div class="list-item complete ">
              <span class="index-num index-now"></span>
              <div class="list-text now-text">
                <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
                <img src="../../../src/assets/Taskdetails/ok.svg" alt="">
              </div>
            </div>
          </template>
        </template>
      </template>
      <template v-if="task.task_type == 3">
        <template v-if="task.current_step == 0">
          <div class="list-item complete">
            <span class="index-num index-now"></span>
            <div class="list-text now-text">
              <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
            </div>
          </div>
        </template>
        <template v-for="step in task.task_steps">
          <div  class="list-item" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text"> 
              <span>完成{{step.amount}}，奖励¥{{step.reward}}</span>
            </div>
          </div>
          <template v-if="task.current_step == step.step">
            <div class="list-item complete">
              <span class="index-num index-now"></span>
              <div class="list-text now-text">
                <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
                <img src="../../../src/assets/Taskdetails/ok.svg" alt="">
              </div>
            </div>
          </template>
        </template>
      </template>
      <!-- 推广员金额 -->
      <template v-if="task.task_type == 4">
        <template v-if="task.current_step == 0">
          <div class="list-item complete-green">
            <span class="index-num index-now"></span>
            <div class="list-text now-text">
              <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
            </div>
          </div>
        </template>
        <template v-for="step in task.task_steps">
          <div  class="list-item" v-bind:class="{ 'complete-green': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text green"> 
              <span>完成{{step.amount}}，奖励¥{{step.reward}}</span>
            </div>
          </div>
          <template v-if="task.current_step == step.step">
            <div class="list-item complete-green">
              <span class="index-num index-now"></span>
              <div class="list-text now-text">
                <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
                <img src="../../../src/assets/Taskdetails/ok.svg" alt="">
              </div>
            </div>
          </template>
        </template>
      </template>
      <!-- 推广员佣金 -->
      <template v-if="task.task_type == 5">
        <template v-if="task.current_step == 0">
          <div class="list-item complete-green">
            <span class="index-num index-now"></span>
            <div class="list-text now-text">
              <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
            </div>
          </div>
        </template>
        <template v-for="step in task.task_steps">
          <div  class="list-item" v-bind:class="{ 'complete-green': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text green"> 
              <span>完成订单，奖励订单总额{{ (step.reward * 100).toFixed(2) }}%</span>
            </div>
          </div>
          <template v-if="task.current_step == step.step">
            <div class="list-item complete-green">
              <span class="index-num index-now"></span>
              <div class="list-text now-text">
                <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
                <img src="../../../src/assets/Taskdetails/ok.svg" alt="">
              </div>
            </div>
          </template>
        </template>
      </template>
      <!-- 推广员推广新人 -->
      <template v-if="task.task_type == 6">
        <template v-if="task.current_step == 0">
          <div class="list-item complete-green">
            <span class="index-num index-now"></span>
            <div class="list-text now-text">
              <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
            </div>
          </div>
        </template>
        <template v-for="step in task.task_steps">
          <div  class="list-item" v-bind:class="{ 'complete-green': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text green"> 
              <span>完成{{step.amount}}，奖励¥{{step.reward}}</span>
            </div>
          </div>
          <template v-if="task.current_step == step.step">
            <div class="list-item complete-green">
              <span class="index-num index-now"></span>
              <div class="list-text now-text">
                <span>已完成{{ task.CurrentAmount }}<i v-show="task.is_have_return" class="redText" @click="showReturn=!showReturn">有退货</i></span>
                <img src="../../../src/assets/Taskdetails/ok.svg" alt="">
              </div>
            </div>
          </template>
        </template>
      </template>
    </div>
<!-- end of list 任务详情  <= 我的任务-->
    <div v-if="task.current_step != 0" class="state-text">
      截至目前获得<span>¥{{ task.current_reward }}</span>奖励，预计<span>{{ (task.balance_end_time || '').slice(0,10) }}</span>结算
    </div>
    <div class="regret" v-if="notStandard">
      很遗憾任务<span class="sorry">未达标</span>
    </div>
    <!-- <span class="state">{{isOK}}</span> -->
  </div>
  <div class="task-rule">
    <h2>任务规则</h2>
    <p>{{ task.description }}</p>
  </div>
  <div class="task-orders" v-if="task.task_type==0 || task.task_type==1 || task.task_type==2 || task.task_type==3">
    <h2>匹配订单</h2>
    <ul class="order-list clearfix" id="">
      <li v-for="order in task.orders" @click = 'goTo(order.user_order_id)'>
        <span class="return">{{ order.order_code }}</span>
        <i v-if="order.is_have_return">退</i>
        <a href="javascript:;">￥{{ order.order_money }}</a>
      </li>
    </ul>
  </div>
  <!-- 推广员任务 匹配 -->
  <div class="task-orders" v-else>
    <h2>详情</h2>
    <ul class="detail-list clearfix" id="">
      <li v-for="order in task.orders" @click = 'goTo(order.user_order_id)'>
        <span>{{ order.normal_user }}</span>
        <!-- 根据不同的任务类型显示不同的字段 -->
        <span class="detail-lpt" v-if="task.task_type==4 || task.task_type==5">¥{{ order.amount }}</span>
        <span class="detail-lpt" v-if="task.task_type==6">绑定时间: {{ order.bind_order_time }}</span>
      </li>
    </ul>
  </div>
  <!-- 普通任务退货详情 -->
  <div v-show="showReturn" class="shadow" >
  <!-- 佣金任务 -->
    <div class="return-cont" v-if="task.task_type == 3">
      <div class="r-title">退货详情<i class="closed" @click="showReturn=!showReturn"></i></div>
      <div class="cont">
        <div class="return-price">
          <p>当前完成:<span>&nbsp;&nbsp;{{ parseInt(task.CurrentAmount) }}</span></p>
          <p>退货总计:<span>&nbsp;&nbsp;{{ parseInt(task.return_amount) }}</span></p>
          <p>历史完成:<span>&nbsp;&nbsp;{{ parseInt(historyFinished) }}</span></p>
        </div>
        <ul class="return-list">
          <li v-for="order in task.return_orders">
            <p>订单号:{{order.order_code}}</p>
            <p>退货:<span>&nbsp;&nbsp;{{ parseInt(order.return_amount) }}</span></p>
          </li>
        </ul>
      </div>
    </div>
  <!-- 金额任务 -->
    <div class="return-cont" v-else>
      <div class="r-title">退货详情<i class="closed" @click="showReturn=!showReturn"></i></div>
      <div class="cont">
        <div class="return-price">
          <p>当前完成:<span>&nbsp;&nbsp;¥{{ task.CurrentAmount }}</span></p>
          <p>退货总计:<span>&nbsp;&nbsp;¥{{ task.return_amount }}</span></p>
          <p>历史完成:<span>&nbsp;&nbsp;¥{{ historyFinished }}</span></p>
        </div>
        <ul class="return-list">
          <li v-for="order in task.return_orders">
            <p>订单号:{{order.order_code}}</p>
            <p>退货:<span>&nbsp;&nbsp;¥{{ order.return_amount }}</span></p>
          </li>
        </ul>
      </div>
    </div>
  </div>
  <loading :show="showLoading" ></loading>
</main>
</template>

<script>
export default {
  data () {
    return {
      headerConfig: {
        title: "任务详情",
        back: true,
        fix: true
      },
      task: {},
      showReturn: false,
      showLoading: false
    }
  },
  computed:{
    isOK: function(){
      if (this.task.current_step != 0) {
        switch(this.task.is_balanced){
          case 1:
            return "待结算";
            break;
          case 2:
            return "已结算";
            break;
          default:
            break;
        }
      }
    },
    standard: function () {
      return this.task.is_start == 2 && this.task.current_step != 0
    },
    notStandard: function () {
      return this.task.is_start == 2 && this.task.current_step == 0
     },
    historyFinished: function () {
      let historyFinished = parseFloat(this.task.CurrentAmount) + parseFloat(this.task.return_amount)
      historyFinished = historyFinished.toFixed(2)
      return historyFinished
    }
  },
  methods: {
    getStatus: function (s) {
      return {
        1 : "开始",
        2 : "已结束",
        3 : "进行中",
        4 : "待结算",
        5 : "已结算"
      }[s]
    },
    getStatusClass: function (s) {
      return {
        1 : "s1",
        2 : "s2",
        3 : "s3",
        4 : "s4",
        5 : "s5"
      }[s]
    },
    goTo: function(id) {
      this.$router.go({
        path: '/order/' + id
      })
    },
    getStep: function (obj) {
      var str = '';
      var len = 0;
      for ( var item in obj) {
        len++
      }
      if (len == 1) {
        return str
      } else {
        return obj.step
      }
    },
    load: function(){
      this.showLoading = true;
      let data = {
        params: {
          user_task_id: this.$route.params.id
        }
      }
      Vue.http.get("/tasks/user_task_details.json", data).then((o)=>{
        this.task = o.json().data
        this.showLoading = false;
      })
    }
  },
  ready: function(){
    this.load()
  }
}

</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
main{
  min-height: 100%;
  background-color: #7eccff;
  padding: 4rem 0.4rem 1rem;
  @at-root .content-box{
    background-color: #fff;
    border-radius: 0.5rem;
    padding: 0 1.2rem;
    position: relative;
    background-size: 6.12rem auto;
    background-position: 98% 1rem;
    background-repeat: no-repeat;
    &.ok {
      background-image:url("../../assets/task/ok.png");
    }
    &.fail {
      background-image:url("../../assets/task/not_ok.png");
    }
    &::after,
    &::before{
      content: "";
      width: 8.4rem;
      height: 1.8rem;
      position: absolute;
      top: -2.4rem;
      background-position: center center;
      background-repeat: no-repeat;
      background-size: 100% 100%;
    }
    &::before{
      background-image: url("../../../src/assets/Taskdetails/bj-left.svg");
      left: 1rem;
    }
    &::after {
      background-image: url("../../../src/assets/Taskdetails/bj-right.svg");
      right: 1rem;
    }
    .content-item {
      text-align: center;
      .state-tip {
        color: #fff;
        &.s1 {
          background-color: #44B6B0;
        }
        &.s2 {
          background-color: #909090;
        }
        &.s3 {
          background-color: #FF6B6B;
        }
        &.s4 {
          background-color: #FFA200;
        }
        &.s5 {
          background-color: #44B6B0;
        }
      }
      &::before{
        content: "";
        display: table;
      }
      span{
        display: inline-block;
        height: 1.7rem;
        line-height: 1.7rem;
        padding: 0 1.6rem;
        background-color: #17A2FD;
        color: #fff;
        border-radius: 0.85rem;
        margin-bottom: 1rem;
      }
      .end{
        background-color: #909090;
      }
    }
    .img-box{
      width: 6rem;
      height: 6rem;
      margin: 0 auto;
      margin-top: -3rem;
      border-radius: 50%;
      overflow: hidden;
      margin-bottom: -0.85rem;
      img{
        width: 100%;
        height: 100%;
        border-radius: 50%;
      }
    }
    p{
      font-size: 1.4rem;
      line-height: 2.8rem;
    }
    .time{
      font-size: 1.4rem;
      color: #909090;
      &.no {
        color: #909090;
      }
    }
    margin-bottom: 0.8rem;
  }
  // 已结束
  .end{
    .now-text img,
    .state{
      display: block !important;
    }
    .state{
    }
    
    // .stateEnd{
    //   background-color: #909090;
    // }
  }
  @at-root .cont-list{
    padding: 2rem 0;
    border-top: 1px solid #f0f0f0;
    border-bottom: 1px solid #f0f0f0;
    .list-item{
      // height: 2.2rem;
      font-size: 1.2rem;
      line-height: 2.2rem;
      margin-bottom: 1.6rem;
      position: relative;
      &::before,
      &::after{
        position: absolute;
        background-color: #E0E0E0;
        content: "";
        display: block;
        width: 0.1rem;
        // height: 3.8rem;
        height: 3.8rem;
        left: 5%;
      }
      &::before{
        bottom: 1.1rem;
      }
      &::after{
        top: 1.1rem;
      }
    }
    .list-item:first-child{
      &::before{
        display: none;
      }
    }
    .list-item:last-child{
      &::after{
        display: none;
      }
    }
    .complete {
      &::before {
        background-color: #17A2FD;
      }
      .index-num {
        /*完成后样式*/
        background-image: url(../../../src/assets/TaskDetails/start-blue.svg);
        &.index-now{
          background-image: url("../../../src/assets/TaskDetails/yuan.svg") !important;
          background-size: 0.8rem 0.8rem;
        }
      }
      .now-text {
        width: auto;
        color: #17A2FD;
        position: relative;
        span{
          // width: auto;
        }
        img {
          height: 5rem;
          width: auto;
          position: absolute;
          right: 5rem;
          top: -1.4rem;
          display: none;
        }
        i{
          float: right;
        }
      }
      .redText {
        color: #EC4D2D;
      }
      .list-text span,
      .now-text {
        background-image: none!important;
      }
    }
    /*推广员*/
    .complete-green {
      &::before {
        background-color: #70BA3F;
      }
      .index-num {
        /*完成后样式*/
        background-image: url(../../../src/assets/TaskDetails/start-green.png);
        &.index-now{
          background-image: url("../../../src/assets/TaskDetails/yuan-green.png") !important;
          background-size: 0.8rem 0.8rem;
        }
      }
      .now-text {
        width: auto;
        color: #17A2FD;
        position: relative;
        span{
          // width: auto;
        }
        img{
          height: 5rem;
          width: auto;
          position: absolute;
          right: 5rem;
          top: -1.4rem;
          display: none;
        }
        i {
          float: right;
        }
      }
      .redText {
        color: #EC4D2D;
      }
      .list-text span,
      .now-text {
        background-image: none!important;
      }
      .list-text {
        color: #70BA3F;

      }
    }
    .have-return {
      &::before {
        bottom: 3rem;
      }
    }
    .have-return .now-text {
        span{
          width: 90% !important;
        }
        img{
          display: none !important;
        }
      }
    .index-num{
      display: block;
      width: 10%;
      height: 2.2rem;
      line-height: 2.4rem;
      margin-bottom: -2.2rem;
      text-align: center;
      z-index: 1;
      position: relative;
      color: #fff;
      background: url("../../../src/assets/TaskDetails/start-gray.svg") center center no-repeat;
      background-size: 2.1rem 2.1rem;
    }
    
    .list-text {
      color: #606060;
      span{
        display: inline-block;
        padding:0  0.8rem;
        width: 90%;
        height: 100%;
        margin-left: 10%;
        box-sizing: border-box;
        background: url("../../../src/assets/TaskDetails/lock.svg") 24rem center no-repeat #f8f8fd;
        background-size: 1.2rem auto;
      }
      &.green {
        span {
          background: url("../../../src/assets/TaskDetails/lock-green.png") 24rem center no-repeat #f8f8fd;
          background-size: 1.2rem auto;
        }
      }
    }
  }
  .state-text{
      font-size: 1.2rem;
      // line-height: 4rem;
      padding: 1.3rem 0;
      color: #606060;
      span{
        color: #F2643A;
      } 
  }
  .regret {
    font-family:PingFangSC-Regular;
    font-size:1.2rem;
    color:#606060;
    line-height: 4rem;
    .sorry {
        color: #F2643A;
      }
  }
  .state{
    position: absolute;
    font-size: 1.2rem;
    color: #17A2FD;
    right: 1.6rem;
    top: 1.2rem;
    display: none;
  }
  .task-orders {
    padding-bottom: .4rem;
    .detail-list {
      padding: 1.5rem 1.2rem 1rem;
      border-radius: 0.5rem;
      background-color: #fff;
      li {
        width: 100%;
        height: 4rem;
        padding-left: 2.2rem;
        line-height: 4rem;
        border-bottom: 1px solid #e0e0e0;
        font-family: STXihei;
        font-size: 1.3rem;
        color: #606060;
        background: url(../../assets/TaskDetails/character.png) left center no-repeat;
        background-size: 1.5rem auto;
        .detail-lpt {
          float: right;
        }
      }
    }
  }
  .task-orders h2,
  .task-rule h2{
    font-size: 1.4rem;
    height: 3.2rem;
    line-height: 3.2rem;
    background-size: 17rem 3.2rem;
    background-repeat: no-repeat;
    margin-bottom: -0.8rem;
    box-sizing: border-box;
  }
  .task-rule p,
  .task-orders .order-list{
    padding: 1.5rem 1.2rem 1rem;
    border-radius: 0.5rem;
    background-color: #fff;
  }
  .task-rule{
    color: #606060;
    margin-bottom: 0.8rem;
    position: relative;
    &::after{
      content: "";
      width: 8.4rem;
      height: 1.8rem;
      position: absolute;
      right: 1rem;
      top: 0;
      background: url("../../../src/assets/Taskdetails/bj-right.svg") center center no-repeat;
      background-size: 100% 100%;
    }
    h2{
      padding-left: 4.3rem;
      background-image: url("../../../src/assets/Taskdetails/left-title.svg");
      background-position: -1px top;
    }
  }
  .task-orders{
    color: #606060;
    position: relative;
    &::before{
      content: "";
      width: 8.4rem;
      height: 1.8rem;
      position: absolute;
      left: 1rem;
      top: 0;
      background: url("../../../src/assets/Taskdetails/bj-left.svg") center center no-repeat;
      background-size: 100% 100%;

    }
    h2{
      text-align: right;
      padding-right: 4.3rem;
      background-image: url("../../../src/assets/Taskdetails/right-title.svg");
      background-position: right top;
    }
    .order-list{
      li{
        padding-left: 2.4rem;
        background: url("../../../src/assets/Taskdetails/file-icon.svg") left center no-repeat;
        background-size: 2rem 2rem;
        font-size: 1.2rem;
        line-height: 3rem;
        border-bottom: 1px solid #f0f0f0;
        i {
          padding: 1px;
          border: 1px solid #606060;
          border-radius: 3px;
        }
      }
      li:last-child{
        border-bottom: none;
      }
      a{
        color: #606060;
        float: right;
        padding-right: 1.3rem;
        background: url("../../../src/assets/Taskdetails/right-icon.svg") right center no-repeat;
        background-size: auto 1rem;
      }
    }
  }
}
.shadow{
  position: fixed;
  width: 100%;
  height: 100%;
  left: 0;
  top: 0;
  z-index: 199;
  background-color: rgba(0,0,0,.5);
  .return-cont{
    width: 25rem;
    /*height: 27.5rem;*/
    position: absolute;
    left: 50%;
    top: 50%;
    margin-left: -12.25rem;
    margin-top: -13.75rem;
    border: 1px solid #e0e0e0;
    border-radius: 1rem;
    box-sizing: border-box;
    background-color: #fff;
    color: #606060;
    font-size: 1.4rem;
    line-height: 2.8rem;
    padding: 4.8rem 1.2rem 0.3rem;
    position: relative;
    overflow: hidden;
  }
  .r-title{
    font-size: 1.6rem;
    text-align: center;
    line-height: 4.8rem;
    height: 4.8rem;
    width: 100%;
    position :absolute;
    left: 0;
    top: 0;
    background-color: #fff;
    color: #313034;
    i{
      position: absolute;
      right: 0.5rem;
      top: 0.7rem;
      width: 2rem;
      height: 2rem;
      background: url('../../assets/Taskdetails/closed.svg') center center no-repeat;
      background-size: 100% 100%;
    }
  }
  .cont{
    height: 22rem;
    overflow-y: scroll;
  }
  .return-price{
    text-indent: center;
    span{
      color: #17A2FD;
    }
  }
  .return-list{
    height: 10rem;
    // border-top: 1px solid #e0e0e0;
    li{
      border-top: 1px solid #e0e0e0;
    }
  }
}

h2,p,ul{
  margin: 0;
  padding: 0;
}

i{
  font-style: normal;
}
ul{
  list-style: none;
}
.region-limit {
    position: absolute;
    top: 1.5rem;
    left: 1.5rem;
    color: #ec4d2d;
}
</style>
