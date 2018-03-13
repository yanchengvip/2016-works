<template>
  <page-header :config='headerConfig'></page-header>
  <main>
    <div id="wrapper" class="content-box" v-infinite-scroll="getList()" infinite-scroll-disabled="busy" infinite-scroll-distance="0" >
      <task-item @click='goTo(task.user_task_id)' :data='task' :done='headerConfig.tabs[1].active' v-for="task in tasks"></task-item>
      <promoter-item @click='goTo(task.user_task_id)' :data='task' :done='headerConfig.tabs[1].active' v-for="task in tasks"></promoter-item>
    </div>
  </main>
  <footer-nav></footer-nav>
  <loading :show="showLoading" ></loading>
  <!-- <confirm :show.sync="showConfirm" cancel-text='使用旧版' :on-cancel="goToOld">旧版本将于9月19日停用已为您切换至新版本</confirm> -->
</template>

<script>
import TaskItem from './task-item'
import PromoterItem from './promoter-item'
import Confirm from '../parts/confirm'


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
      tasks: [],
      showLoading: false,
      showConfirm: false,
      oldToken: '',
      hasMore: true,
      busy: false,
      num: 1,
      per_page: 7
    }
  },
  components: {
    'task-item': TaskItem,
    'promoter-item': PromoterItem,
    'confirm': Confirm
  },
  methods: {
    goTo: function (id) {
      this.$router.go({
        path: '/task/'+id
      })
    },
    goToOld: function () {
      this.showConfirm = false
      location.href="http://yc2.tunnel.jinhuobao.com.cn/?remember_token="+this.oldToken
    },
    fetchData: function () {
      let data = {
        params: {
          page: 1,
          per_page: this.per_page,
          status: this.headerConfig.tabs[0].active ? 4: 5
        }
      }
      this.showLoading = true
      Vue.http.get('/tasks/user_tasks.json', data).then((o)=>{
        this.showLoading = false
        this.tasks = o.json().data
      })
    },
    switchTab: function (index) {
      this.headerConfig.tabs[index].active = true
      let otherIndex = Math.abs(index-1)
      this.headerConfig.tabs[otherIndex].active = false
    },
    getList: function(){
      // this.busy = true
      if(this.hasMore){
        this.num += 1
        let data = {
          params: {
            page: this.num,
            per_page: this.per_page,
            status: this.headerConfig.tabs[0].active ? 4: 5
          }
        }
        Vue.http.get('/tasks/user_tasks.json',data).then((o)=>{
          if(o.json().data.length == 0){
            this.hasMore = false
            this.busy = true
          }
          this.tasks = this.tasks.concat(o.json().data)
        })
      }
    }
  },
  ready: function () {
    // 此处需要先检查tab的状态之后再fetchdata,否则可能会引起返回页面不正确
    this.switchTab(window.store.activeTab)
    this.fetchData()
    // if (this.$route.query.is_older==2) {
    //   let oldToken = this.$route.query.old_token
    //   this.oldToken = oldToken
    //   this.showConfirm = true
    // }
    let now = new Date()
    let start = new Date("2016/10/01 00:00:00")
    let end = new Date("2016/10/08 00:00:00")
    if (now > start && now < end) {
        if (!sessionStorage.getItem('20161001')) {
            alert('“通知：部分银行国庆期间服务暂停，奖励延迟至节后发放”')
            sessionStorage.setItem('20161001', '1')
        }
    }
  },
  watch: {
    'headerConfig.tabs[0].active': function (newVal, oldVal) {
      this.fetchData()
      if (newVal) {
        window.store.activeTab = 0
      } else {
        window.store.activeTab = 1
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
main {
  padding: 0 .4rem;
  padding-bottom: 5.5rem;
}
</style>
