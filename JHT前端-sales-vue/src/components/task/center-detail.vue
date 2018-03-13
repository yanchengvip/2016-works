<!-- 任务详情页 -->
<template>
<page-header :config='headerConfig'></page-header>
  <main class="">
    <div class="content-box">
      <div class="region-limit" v-show="task.belong_city">仅限{{ task.belong_city }}使用</div>
      <div class="content-item">
        <div class="img-box">
          <img :src="task.task_logo" alt="">
        </div>
        <p class="title">{{ task.title }}</p>
      </div>
      <div class="time-box">
        <p class="">任务时间：<span v-text="task.begin_time | substr "></span> - <span v-text="task.end_time | substr "></span> </p>
        <p class="">结算时间：<span v-text="task.balance_end_time | substr"></span></p>
      </div>
      <p class="task-text">
        {{ task.description }}
      </p>
      <div class="cont-list">
        <!-- <div class="list-item complete">
          <span class="index-num">1</span>
          <div class="list-text">
            <span>完成¥15000，奖励¥200</span>
          </div>
        </div>
        <div class="list-item complete">
          <span class="index-num">2</span>
          <div class="list-text">
            <span>完成¥30000，奖励¥500</span>
          </div>
        </div>
        <div class="list-item">
          <span class="index-num">3</span>
          <div class="list-text">
            <span>完成¥50000，奖励¥800</span>
          </div>
        </div> -->
        <template v-if="task.type == 0">
          <div v-for="step in task.task_steps" class="list-item" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成订单，奖励订单总额{{(step.reward * 100).toFixed(2)}}%</span>
            </div>
          </div>
        </template>
        <template v-if="task.type == 1">
          <div v-for="step in task.task_steps" class="list-item" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成{{step.amount}}，奖励<strong>¥{{step.reward}}</strong></span>
            </div>
          </div>
        </template>
        <template v-if="task.type == 2">
          <div v-for="step in task.task_steps" class="list-item" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成{{step.amount}}，奖励<strong>¥{{step.reward}}</strong></span>
            </div>
          </div>
        </template>
        <template v-if="task.type == 3">
          <div v-for="step in task.task_steps" class="list-item" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成{{step.amount}}，奖励<strong>¥{{step.reward}}</strong></span>
            </div>
          </div>
        </template>
        <!-- 推广员任务类型 -->
        <template v-if="task.type == 4">
          <div v-for="step in task.task_steps" class="list-item promoter" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成{{step.amount}}，奖励<strong>¥{{step.reward}}</strong></span>
            </div>
          </div>
        </template>
        <template v-if="task.type == 5">
          <div v-for="step in task.task_steps" class="list-item promoter" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成订单，奖励订单总额<strong>{{(step.reward * 100).toFixed(2)}}%</strong></span>
            </div>
          </div>
        </template>
        <template v-if="task.type == 6">
          <div v-for="step in task.task_steps" class="list-item promoter" v-bind:class="{ 'complete': task.current_step >= step.step}">
            <span class="index-num">{{ task.task_steps.length == 1 ? '' : step.step }}</span>
            <div class="list-text">
              <span>完成{{step.amount}}，奖励<strong>¥{{step.reward}}</strong></span>
            </div>
          </div>
        </template>
      </div>
    </div>
    <ul class="bottom-box" :class="{ 'green' : task.type == 4 || task.type == 5 || task.type == 6 }">
      <li class="money" v-if="task.type == 0 || task.type == 5">
        奖励{{(task.task_steps[0].reward * 100).toFixed(2)}}%
      </li>
      <li class="money" v-if="!(task.type == 0 || task.type == 5)">
        最多奖励¥{{ mostReward }}
      </li>
      
      <li class="state" :class="{'is-have': task.is_start != 2, 'end': task.is_start == 2}">
        <span v-if="task.is_start != 2">已领取</span>
        <span v-if="task.is_start == 2">已结束</span>
      </li>
    </ul>
  </main>
</template>

<script>
export default {
  data () {
    return {
      headerConfig: {
        title: "任务详情",
        back: true
      },
      task: {}
    }
  },
  methods: {
    steps: function(obj) {
      if (obj.length == 1) {
        step = ''
      } else if (obj.length > 1) {
        step = steps.step
      }
      return step
    }
  },
  computed: {
    'mostReward': function () {
      let steps = this.task.task_steps
      if (_.last(steps)) {
        var mostReward = _.last(steps).reward
      }
      // let mostReward = _.last(steps).reward
      return mostReward
    }
  },
  ready: function () {
    let data = {
      params: {
        task_id: this.$route.params.id
      }
    }
    Vue.http.get('/tasks/task_details.json', data).then((o)=>{
      this.task = o.json().data
    })
  }
}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
main{
  height: 100%;
  background-color: #7eccff;
  padding: 4rem 0.4rem 1rem;
  .region-limit {
    position: absolute;
    z-index: 9;
    top: 1rem;
    left: .5rem;
    color: #ec4d2d;
  }
  @at-root .content-box{
    background-color: #fff;
    border-radius: 0.5rem;
    padding: 0 1.2rem;
    position: relative;
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
    &::after{
      background-image: url("../../../src/assets/Taskdetails/bj-right.svg");
      right: 1rem;
    }
    .content-item{
      text-align: center;
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
    }
    .img-box{
      width: 6rem;
      height: 6rem;
      margin: 0 auto;
      margin-top: -3rem;
      border-radius: 50%;
      overflow: hidden;
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
      color: #909090;
    }
  }
  .task-text{
    font-size: 1.2rem;
    line-height: 2.2rem;
    padding: 1rem 0;
  }
  .time-box{
    font-size: 1.3rem;
    line-height: 2.5rem;
    padding: 0.8rem 0;
    border-top: 1px solid #f0f0f0;
    border-bottom: 1px solid #f0f0f0;
    span{
      color: #909090;
    }
  }
  @at-root .cont-list{
    padding: 2rem 0;
    border-top: 1px solid #f0f0f0;
    border-bottom: 1px solid #f0f0f0;
    .list-item{
      height: 2.2rem;
      font-size: 1.2rem;
      line-height: 2.2rem;
      margin-bottom: 1.6rem;
      position: relative;
      &::before,
      &::after{
        position: absolute;
        background-color: #17A2FD;
        content: "";
        display: block;
        width: 0.1rem;
        height: 3.8rem;
        left: 5%;
      }
      &::before{
        bottom: 1.1rem;
      }
      &::after{
        top: 1.1rem;
      }
      /*推广员*/
      &.promoter {
        &::before,
        &::after {
          position: absolute;
          background-color: #70BA3F;
          content: "";
          display: block;
          width: 0.1rem;
          height: 3.8rem;
          left: 5%;
        }
        .index-num {
          display: block;
          width: 10%;
          height: 2.2rem;
          line-height: 2.4rem;
          margin-bottom: -2.2rem;
          text-align: center;
          z-index: 1;
          position: relative;
          color: #fff;
          background: url("../../../src/assets/TaskDetails/start-green.png") center center no-repeat;
          background-size: 2.1rem 2.1rem;
        }
        .list-text {
          /*color: #70BA3F;*/
        }
      }
      /*start && text*/
      .index-num {
        display: block;
        width: 10%;
        height: 2.2rem;
        line-height: 2.4rem;
        margin-bottom: -2.2rem;
        text-align: center;
        z-index: 1;
        position: relative;
        color: #fff;
        background: url("../../../src/assets/TaskDetails/start-blue.svg") center center no-repeat;
        background-size: 2.1rem 2.1rem;
      }
      .list-text{
        color: #606060;
        span{
          display: inline-block;
          padding:0  0.8rem;
          width: 90%;
          height: 100%;
          margin-left: 10%;
          box-sizing: border-box;
          background-color: #f8f8fd;
          background-size: 1.2rem auto;
          strong {
            color: #FF6B6B;
          }
        }
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

  }
}
.bottom-box{
  position: fixed;
  left: 0;
  bottom: 0;
  width: 100%;
  height: 4rem;
  line-height: 4rem;
  text-align: center;
  font-size: 1.6rem;
  color: #17A2FD;
  background-color: #fff;
  z-index: 9;
  border-top: 1px solid #e0e0e0;
  &.green {
    color: #70BA3F;
  }
  li{
    float: left;
    width: 50%;
    box-sizing: border-box;
  }
  .end{
    background-color: #c0c0c0;
    color: #fff;
  }
  .is-have{
    background-color: #f3f4f5;
    border-left: 1px solid #c0c0c0;
    color: #b0b0b0;
    span{
      padding-left: 2.8rem;
      background: url("../../../src/assets/TaskDetails/is-have.svg") left center no-repeat;
      background-size: 2rem 2rem;
      display: inline-block;
      height: 2rem;
      line-height: 2rem;
    }
  }
}
h2,p,ul{
  margin: 0;
  padding: 0;
}
ul{
  list-style: none;
}
</style>
