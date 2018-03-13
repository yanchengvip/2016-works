<template>
  <page-header :config='headerConfig'></page-header>
  <main class="pure-g">
    <div  id="wrapper" class="content-box" v-infinite-scroll="getList()" infinite-scroll-disabled="busy" infinite-scroll-distance="10">
      <div class="task-item pure-u-1-2" :class='{done: isDone(task)}' v-for="task in tasks" @click='goTo(task.id)'>
        <div class="task-item-wrapper">
          <div class="top">
            <div class="region-limit" v-show="task.belong_city">仅限{{ task.belong_city }}使用</div>
            <div class="img">
              <img :src="task.task_logo" alt="此处应有图">
              <div class="tip">
                <span v-if="isOver(task)">已结束</span>
                <span v-if="!isOver(task)">{{ task.end_days }}后结束</span>
              </div>
            </div>
            <div class="title">
              {{ task.title }}
            </div>
          </div>
          <div class="middle">
            <div class="price">{{getPrice(task)}}</div>
          </div>
          <div class="bottom">
            <a href="javascript:;" class="center-btn"><i class="icon" v-if="!isDone(task)">&#xe609;</i>{{ isDone(task) ? '已结束' : '已领取'}}</a>
          </div>
        </div>
      </div>
    </div>
  </main>
  <footer-nav></footer-nav>
  <loading :show="showLoading" ></loading>
</template>

<script>
import TaskItem from './task-item'

export default {
  data () {
    return {
      headerConfig: {
        title: '任务中心'
      },
      tasks: [],
      showLoading: false,
      priceText:"",
      num:3,
      hasMore: true,
      busy: false,
      per_page: 10
    }
  },
  components: {
    'task-item': TaskItem
  },
  ready: function () {
    this.fetchData()
  },
  methods: {
    goTo: function (id) {
      this.$router.go({
        path: '/task/center/'+id
      })
    },
    getPrice :function(obj){
      if (obj.type == 0 || obj.type == 5) {
        return (obj.task_steps[0].reward * 100).toFixed(2) + "%"
      } else {
        if(obj.task_steps.length > 1){
          return "￥"+ obj.task_steps[0].reward + "-￥" + obj.task_steps[obj.task_steps.length-1].reward
        }else{
          return "￥" + obj.task_steps[0].reward
        }
      }
      
    },
    fetchData: function () {
      let data = {
        page: this.num,
        per_page: this.per_page
      }
      this.showLoading = true
      Vue.http.get('/tasks/list.json', data).then((o)=>{
        this.showLoading = false
        this.tasks = o.json().data
        // console.log(o.json().data)
      })
    },
    getList: function(){
      this.busy = true
      if(this.hasMore){
        this.num += 1
        let data = {
          params: {
            page: this.num,
            per_page: this.per_page
          }
        }
        Vue.http.get('/tasks/list.json',data).then((o)=>{
          if(o.json().data.length == this.per_page){
            this.hasMore = true
            this.busy = false
          }
          this.tasks = this.tasks.concat(o.json().data)
        })
      }
    },
    isDone: function (task) {
      // let end_days = task.end_days.replace(/\D/g, '') || 0
      return task.is_start == 2
    }
    // isOver:function(task) {
    //   // let end_days = task.end_days.replace(/\D/g, '') || 0
    //   return task.is_start == 2 || task.is_start == 4 || task.is_start == 5
    // }
  }
}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
main {
  padding: 0 .4rem;
  padding-bottom: 5.5rem;
}
.task-item {
  margin-top: .8rem;
  &:nth-child(2n+1) {
    .task-item-wrapper {
      margin-right: .2rem;
    }
  }
  &:nth-child(2n) {
    .task-item-wrapper {
      margin-left: .2rem;
    }
  }
}
.top {
  position: relative;
  height: 11rem;
  padding-top: 1.2rem;
  padding-bottom: .8rem;
  background-color: #FFF;
  border-top-left-radius: .4rem;
  border-top-right-radius: .4rem;
  .region-limit {
    position: absolute;
    z-index: 9;
    top: 1rem;
    left: .5rem;
    color: #ec4d2d;
  }
}
.img {
  position: relative;
  img {
    width: 7rem;
    height: 7rem;
    display: block;
    margin: 0 auto;
    border-radius: 50%;
    line-height: 7rem;
    text-align: center;
  }
  .tip {
    text-align: center;
    position: absolute;
    bottom: 0;
    width: 100%;
    span {
      display: inline-block;
      padding: 0 .4rem;
      border-radius: 1rem;
      height: 1.6rem;
      line-height: 1.6rem;
      color: #fff;
      font-size: 1rem;
      background-color: #ec4d2d;
    }
  }
}
.title {
  text-align: center;
  font-size: 1.3rem;
  margin-top: .8rem;
}
.middle {
  background-image: url("../../assets/taskCenter/bg2.png");
  background-repeat: no-repeat;
  background-size: 100% auto;
  background-position: 0 0;
  background-color: #FFF;
  padding-top: .9rem;
  line-height: 2rem;
  font-size: 1.2rem;
  color: #fff;
  .price {
    width: 100%;
    height: 2rem;
   /* padding-left: 5.5rem;*/
    text-align: right;
    padding-right: .3rem;
  }
}
.center-btn {
  display: block;
  text-align: center;
  height: 3.2rem;
  line-height: 3.2rem;
  font-size: 1.4rem;
  color: #fff;
  background-color: #65c6b4;
  border-bottom-left-radius: .4rem;
  border-bottom-right-radius: .4rem;
}
.task-item {
  &.done {
    .tip {
      span {
        background-color: #909090;
      }
    }
    .middle {
      background-image: url("../../assets/taskCenter/bg3.png");
    }
    .center-btn {
      background-color: #909090;
    }
  }
}
</style>
