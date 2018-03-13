<!-- 收入明细 -->
<template>
<page-header :config='headerConfig'></page-header>
<main class="" id="">
  <section v-if="income.length">
    <div class="top-box">
      <p class="top-title">{{text}}</p>
      <p class="top-price">¥{{price}}</p>
      <p class="top-charge">手续费：&nbsp;{{(price*.1).toFixed(2)}}</p>
    </div>
    <div id="wrapper" class="content-box" v-infinite-scroll="getList()" infinite-scroll-disabled="busy" infinite-scroll-distance="0" >    
      <div v-for="item in income" class="content-item">
        <div class="item-title">
          {{item.year_month}}月份收入明细
        </div>
        <ul class="item-list">
          <li v-for="list in item.tasks" @click='goTo(list.id)'>
            <div class="time">
              <p class="big"><span>{{list.balance_end_time.slice(8,10)}}</span>号</p>
              <p class="tip">{{tip}}</p>
            </div>
            <div class="item-img">
              <img :src="list.task_logo" alt="">          
            </div>
            <div class="item-text">
              <p class="big"><span v-show = "text != '待结收入' ">+</span><span>{{list.current_reward}}</span>元</p>
              <p class="return-goods" v-if="list.is_have_return">
                退货扣除<span>{{ list.return_award }}</span>
              </p>  
              <p class="tip">{{list.task_name}}</p>
            </div>
            
          </li>
        </ul>
      </div>
      <!-- <a href="javascript:;"  v-on:click="getList()">测试</a> -->
    </div>
  </section>
  <section class="no-come" v-else>
    <img src="../../assets/mine/no-income.png" alt="">
    <span>暂无收入</span>
  </section>
  
</main>
</template>

<script>
export default {
  data () {
    return {
      headerConfig: {
        title: "收入",
        back: true
      },
      income:[],
      price: "",
      text:"",
      tip:"",
      num: 1,
      url:"",
      hasMore: true,
      busy: false,
      per_page: 7
    }
  },
  methods: {
    goTo: function (id) {
      this.$router.go({
        path: '/task/'+ id
      })
    },
    load: function(){
      var temp = this.$route.params.status
      var url = "";
      if(temp == "yes"){
        this.text="已得收入",
        this.tip="结算"
        this.url="/users/user_balanced.json"
      }else if(temp == "no"){
        this.text="待结收入",
        this.tip="结算"
        this.url="/users/user_not_balanced.json"
      }
      let data = {
        params: {
          page: this.num,
          per_page: this.per_page
        }
      }
      Vue.http.get(this.url,data).then((o)=>{
        this.price = o.json().balance;
        // if(o.json().data.length == this.per_page){
        //   this.hasMore = true
        //   this.busy = false
        // }else{
        //   this.hasMore = false
        // }
        this.income = o.json().data
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
        Vue.http.get(this.url,data).then((o)=>{
          // if(o.json().data.length == this.per_page){
          //   this.hasMore = true
          //   this.busy = false
          // }
          if(o.json().data.length == 0){
            this.hasMore = false
            this.busy = true
          }
          this.income = this.income.concat(o.json().data)
        })
      }
    }
  },
  ready: function(){
    this.load()
  },
  watch:{
    "num":function (newVal,oldVal) {
    }
  }
}

</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
@import '../../styles/base.scss';
main{

  min-height: 100%;
}
.no-come {
  width: 100%;
  height: auto;
  margin-top: 13rem;
  text-align: center;
  img {
    display: block;
    width: 18rem;
    height: auto;
    margin: 0 auto;
  }
  span {
    font-family:PingFangSC-Regular;
    line-height: 4rem;
    font-size:1.3rem;
    color:#909090;
    text-align:justify;
  }
}
.top-box{
  text-align: center;
  color: #fff;
  padding: 2.5rem 0;
  background-color: #2ba9fc;
  background-image:linear-gradient(top,#73d0fb,#2ba9fc);
  margin-bottom: 0.9rem;
}
.top-title{
  font-size: 1.2rem;
  line-height: 2.2rem;
}
.top-price{
  font-size: 3.2rem;
  line-height: 4.2rem;
}
.content-item{
  border-top: 1px solid #e0e0e0;
  border-bottom: 1px solid #e0e0e0;
  background-color: #fff;
  margin-bottom: 1rem;
}
.item-title{
  font-size: 1.2rem;
  color: #404040;
  line-height: 3.2rem;
  padding-left: 1.2rem;
  background: #fff;
  border-bottom: 1px solid #e0e0e0;
}
.item-list{
  padding-left: 1.2rem;
  li{
    position: relative;
    height: 4rem;
    border-bottom: 1px solid #e0e0e0;
    padding: 1rem 0;
    background: url("../../../src/assets/base/right-icon.svg") 28rem  center no-repeat;
    background-size: auto 1.6rem;
    box-sizing: content-box;
  }
  li:last-child{
    border-bottom: none;
  }
  .time,
  .item-img{
    float: left;
  }
  .time{
    width: 4rem;
  }
  .item-img{
    width: 4rem;
    height: 4rem;
    border-radius: 50%;
    overflow: hidden;
    img{
      width: 100%;
      height: 100%;
      vertical-align: top;
    }
  }
  .return-goods {
    font-family:PingFangSC-Regular;
    margin-left: 2rem;
    padding-top: .5rem;
    height: 2.6rem;
    vertical-align: middle;
    display: inline-block;
    font-size: 1rem;
    color: #404040;
    span {
      color: red;
    }
  }
  .big{
    display: inline-block;
    font-size: 1.2rem;
    color: #404040;
    span{
      font-size: 2.1rem;
      line-height: 2.6rem;
    }
  }
  .tip{
    font-size: 1.2rem;
    color: #909090;
  }
  .item-text{
    margin-left: 9.5rem;
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
</style>
