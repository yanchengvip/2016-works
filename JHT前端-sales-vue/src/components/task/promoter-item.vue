<template>
  <!-- 推广员任务 -->
  <div class="task" v-show="data.type==4 || data.type==5 || data.type==6">
    <div class="content" :class="{ grey: data.is_start == 2 && data.current_step == 0 , ok: isOk, 'not-ok': notOk }">
      <div class="head">
        <div class="avatar">
          <img class="logo" :src="data.task_logo">
          <div class="grade" :class="{ no: data.is_start == 2 }">{{ data.current_step }}级</div>
        </div>
        <div class="describe">
          <div class="title">{{ data.title }}</div>
          <div class="region-limit" v-show="data.belong_city">仅限{{ data.belong_city }}使用</div>
        </div>
      </div>
      <!-- 佣金 -->
      <div v-if="data.type==5">
        <div class="total-amount">总金额</div>
        <ul class="commission">
          <li >¥</li>
          <li>0</li>
          <li v-for="item in data.current_amount" :style="{ color: '#70BA3F'  }" track-by="$index">{{ item }}</li>
        </ul>
        <div class="reward">
          <div class="reward-num">奖励金额:&nbsp;<span>{{ data.current_reward }}</span></div>
          <div class="annotation">注:奖励金额 = 总金额 x {{ (rewardProgress[1]*100).toFixed(2) }}%</div>
        </div>
      </div>
      <!-- 金额 || 新人 -->
      <div v-else class="progress-promoter" :style="{backgroundSize: progressPercent+'% 100%'}">{{ progressText }}</div>
      <div class="line"></div>
      <table class="message">
        <tbody>
          <tr>
            <td><img src="../../assets/task/1.svg"></td>
            <td><img src="../../assets/task/people.png"></td>
            <td v-if="data.type != 5"><img src="../../assets/task/3.svg"></td>
          </tr>
          <tr>
            <td v-if="data.is_start == 1 || data.is_start == 3"><span class="main-color">{{data.end_days}}</span>&nbsp;后结束</td>
            <td v-if="data.is_start == 2 || data.is_start == 4 || data.is_start == 5">已结束</td>
            <td>人数<span class="order-num">&nbsp;{{ data.users_num }}</span></td>
            <td v-if="data.type != 5"><span class="reward-num">¥{{rewardProgress[0]}}</span>/¥{{rewardProgress[1]}}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  <!-- 推广员佣金任务 -->
  <!-- <div class="task" v-show="data.type==5">
    <div class="content" :class="{ grey: data.is_start == 2 && data.current_step == 0 , ok: isOk, 'not-ok': notOk }">
      <div class="head">
        <div class="avatar">
          <img class="logo" :src="data.task_logo">
          <div class="grade" :class="{ no: data.is_start == 2 }">{{ data.current_step }}级</div>
        </div>
        <div class="describe">
          <div class="title">{{ data.title }}</div>
          <div class="region-limit" v-show="data.belong_city">仅限{{ data.belong_city }}使用</div>
        </div>
      </div>
      <div class="total-amount">总金额</div>
      <ul class="commission">
        <li >¥</li>
        <li>0</li>
        <li v-for="item in data.current_amount" :style="{ color: '#70BA3F'  }" track-by="$index">{{ item }}</li>
      </ul>
      <div class="reward">
        <div class="reward-num">奖励金额:&nbsp;<span>¥100</span></div>
        <div class="annotation">注:奖励金额 = 总金额 x 1%</div>
      </div>
      <div class="line"></div>
      <table class="message">
        <tbody>
          <tr>
            <td><img src="../../assets/task/1.svg"></td>
            <td><img src="../../assets/task/2.svg"></td>
          </tr>
          <tr>
            <td v-if="data.is_start != 2"><span class="main-color">{{data.end_days}}</span>&nbsp;后结束</td>
            <td v-if="data.is_start == 2">已结束</td>
            <td>订单<span class="order-num">&nbsp;{{ data.orders_num }}</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div> -->
</template>
<script>
export default {
  data () {
    return {
      
    }
  },
  props: {
    data: {
      default: function () {
          return { 
          }
      }
    },
    done: {
      required: true
    }
  },
  ready: function () {
  },
  computed: {
    'progress': function () {
      let steps = this.data.task_steps
      // if (this.data.current_step == 0){
      //   var begin = 0
      // }else{
      //   var begin = parseInt(steps[this.data.current_step-1].amount) 
      // }
      let begin = parseFloat(this.data.current_amount)
      let end = parseInt(_.last(steps).amount)
      return [begin, end]
    },
    'progressText': function () {
      let realProgress = this.progress
      realProgress[0] = parseFloat(this.data.current_amount)
      return realProgress.join(' / ')
    },
    'progressPercent': function () {
      let progress = this.progress
      let num = 0
      num = progress[0]/progress[1]
      if (isNaN(num)) {
        num = 0
      }
      return num*100
    },
    'rewardProgress': function() {
      let steps = this.data.task_steps
      let begin = 0;
      if (this.data.current_step == 0) {
        begin = 0
      } else {
        begin = parseFloat(steps[Math.max(this.data.current_step-1, 0)].reward)
      }
      let end = parseFloat(_.last(steps).reward)
      return [begin, end]
    },
    'isOk': function () {
      return this.done && this.data.current_step >= 0
    },
    'notOk': function () {
      return this.done && this.data.current_step == 0
    }
  }
}
</script>
<style lang="scss" scoped>
@import '../../styles/variable.scss';
@import '../../styles/variable.scss';
.task {
    position: relative;
    margin-top: .8rem;
    padding-top: 1.6rem;
    position: relative;
}
.content {
    background-color: #fff;
    border-radius: .4rem;
    padding-bottom: .6rem;
    background-size: 6.12rem auto;
    background-position: 95% 1rem;
    background-repeat: no-repeat;
    &.user {
        padding-top: 3.2rem;
    }
    .region-limit {
        position: absolute;
        top: 3rem;
        left: 1.5rem;
        color: #ec4d2d;
    }
    .head {
      padding: .8rem 0 0 1.3rem;
      /*margin-bottom: 1.4rem;*/
      .avatar {
        position: relative;
        display: inline-block;
        width: 4rem;
        height: 4rem;
        .logo {
          width: 100%;
          height: 100%;
          border-radius: 50%;
        }
        .grade {
          position: absolute;
          bottom: 0rem;
          left: 50%;
          white-space: nowrap;
          height: 1.4rem;
          padding: 0 .5rem;
          background-color: #ec4d2d;
          border-radius: .7rem;
          text-align: center;
          line-height: 1.4rem;
          color: #fff;
          font-family: PingFangSC-Regular;
          font-size: 1rem;
          &.no {
            background: #909090;
          }
        }
      }
      .describe {
        position: relative;
        vertical-align: top;
        display: inline-block;
        .title {
          line-height: 2.1rem;
          display: inline-block;
          color: $title-color;
          font-size: 1.4rem;
          text-align: center;
          text-indent: .8rem;
        }
        .region-limit {
          position: absolute;
          left: 0;
          top: 2rem;
          line-height: 2rem;
          text-indent: .8rem;
          color: #ec4d2d;
        }
      }
      
    }
    &.ok {
      background-image: url("../../assets/task/ok.png");
    }
    &.not-ok {
     background-image: url("../../assets/task/not_ok.png");
    }
    &.grey {
      filter: grayscale(100%);
    }
}
.title {
    color: $title-color;
    font-size: 1.4rem;
    text-align: center;
}
.total-amount {
  text-align: center;
  font-size: 1.3rem;
  color: #404040;
}
.commission {
    margin: 0 4rem;
    height: 1.8rem;
    margin-top: .8rem;
    padding-left: 0;
    line-height: 1.8rem;
    border: 1px solid $text-color;
    border-radius: .4rem;
    display: -webkit-flex;
    display: flex;
    font-size: 1.3rem;
    li {
        list-style: none;
        float: left;
        margin: .4rem 0;
        padding: .1rem .4rem;
        line-height:.9rem;
        text-align: center;
        /*color: #17a2fd;*/
        border-right: 1px solid #909090;
        -webkit-flex: 1;
           -moz-flex: 1;
            -ms-flex: 1;
             -o-flex: 1;
                flex: 1;
    }
    li:last-child{
        border-right: 0;
    }
}
.reward {
    font-family: PingFangSC-Regular;
    margin: .8rem 1.2rem -0.8rem 4rem;
    .reward-num {
        line-height: 2rem;
        font-size: 1.3rem;
        span {
            font-size: 1.6rem;
            text-align: left;
            color: #70BA3F;
        }
    }
    .annotation {
      text-align: right;
      font-size: 1.1rem;
      color: #696969;
    }
}
.progress-promoter {
    margin: 0 1.2rem;
    height: 1.8rem;
    line-height: 1.8rem;
    font-size: 1.2rem;
    text-align: center;
    border: .1rem solid $text-color;
    border-radius: 1rem;
    background-image: url('../../assets/task/por_bar.png');
    background-repeat: no-repeat;
    margin-top: .8rem;
}
.line {
    border-bottom: 1px solid $line-color;
    margin: 0 1.2rem;
    margin-top: 1.25rem;
}
table {
    width: 100%;
    tr:first-child {
        td {
            padding: .8rem 0 .6rem 0;
        }
    }
    td{
        width: 33.3333%;
        text-align: center;
        font-size: 1.2rem;
        img {
            display: inline-block;
            width: 2.4rem;
            height: 2.4rem;
        }
    }
}
.logo {
    position: absolute;
    top: 0;
    left: 50%;
    width: 4rem;
    margin-left: -2rem;
    height: 4rem;
    border-radius: 50%;
}
.grade {
    position: absolute;
    top: 2.5rem;
    left: 50%;
    height: 1.4rem;
    padding: 0 .5rem;
    background: #ec4d2d;
    border-radius:.7rem;
    text-align: center;
    line-height: 1.4rem;
    color: #fff;
    font-family:PingFangSC-Regular;
    font-size:1rem;
    &.no {
        background: #909090;
    }
}
.order-num {
    color: #f5a623;
}
.reward-num {
    color: #ec4d2d;
}
</style>