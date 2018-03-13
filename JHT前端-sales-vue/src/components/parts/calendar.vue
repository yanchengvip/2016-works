<template>
  <div id="calendar" v-show="showSwitch">
    <page-header :config='headerConfig' @click="showSwitch = !showSwitch"></page-header>
    <div class="dates header clearfix">
      <div class="date">日</div>
      <div class="date">一</div>
      <div class="date">二</div>
      <div class="date">三</div>
      <div class="date">四</div>
      <div class="date">五</div>
      <div class="date">六</div>
    </div>
    <div id="calendar-content">
      <template v-for="month in months">
        <div class="month">{{ month.month }}</div>
        <div class="dates clearfix">
          <div class="date" v-for="date in month.dates" :class="{ 'current': currentDate == date.date , 'pass-times': !isDiff(date.date) , 'select': beginDate < getStamp(date.date) && endDate > getStamp(date.date)}" data-date="{{ date.date }}" track-by="$index" @click="onTap" >{{ date.day }}</div>
        </div>
      </template>
    </div>
    <dialog v-show="alertShow" type="alert" title="提示" @weui-dialog-confirm="onAlertConfirm('确定', 2)">
        {{alertMsg}}
    </dialog>
  </div>
</template>
<script>
import moment from 'moment/min/moment.min'
import _ from 'lodash'
// import VueTouch from 'vue-touch'
// Vue.use(VueTouch)
let begin = moment('2016-04-01')
window.moment = moment

let monthEnd = moment(moment.now()).endOf('month')
let range = monthEnd.diff(begin, 'days')

export default {
  data () {
    return {
      alertShow: false,
      alertMsg: '',
      headerConfig: {
        title: '选择日期',
        back: true,
        link: 'javascript:;'
      },
      startTime: [1970,1,1],
      endTime: [1970,1,1]
    }
  },
  props: {
    range: {
      required: false,
      default: range+1
    },
    dateBegin: {
      required: true
    },
    dateEnd: {
      required: true
    },
    showSwitch: {
      required: true
    },

  },
  ready: function () {
    console.log(this.startTime)
  },
  watch: {
    'dateBegin': function (newVal, oldVal) {
      if (!newVal) { //置空的时候
        let elBegin = $('.taped.begin')
        if (elBegin) {
          elBegin.classList.remove('taped')
          elBegin.classList.remove('begin')
        }
        let elEnd = $('.taped.end')
        if (elEnd) {
          elEnd.classList.remove('taped')
          elEnd.classList.remove('end')
        }
      }
    },
    'showSwitch': function (newVal, oldVal) {
      if (newVal) {
        this.scrollBottom()
      } else {
        this.scrollTop()
      }
    }
  },
  computed: {
    months: function () {
      let results = []
      let monthData = {}
      for (let delay in _.range(this.range)) {
        let dateBegin = begin.clone()
        let date = dateBegin.add(delay, 'days')
        let thisMonth = date.year()+'年'+(date.month() + 1)+'月'
        let day = date.date()
        if (thisMonth != monthData.month) {
          if (monthData.month) {
            results.push(_.clone(monthData))
          }
          monthData.month = thisMonth
          monthData.dates = []
          for (let i in _.range(date.day())) {
            monthData.dates.push({'day':'', 'date':''})
          }
        }
        let fullDate = [date.year(), date.month()+1, date.date()]
        // let dateData = date.year() + "-" + (date.month()+1) + "-" + date.date()
        monthData.dates.push({'day':day, 'date':JSON.stringify(fullDate)})
      }
      results.push(_.clone(monthData))
      return results
    },
    currentDate: function () {
      var fullDay = [moment().year(), moment().month()+1, moment().date()]
      return JSON.stringify(fullDay)
    },
    beginDate: function () {
      return moment(this.startTime) 
    },
    endDate: function () {
      return moment(this.endTime)
    }
  },
  methods: {
    momentNow: function() {
      let fullDay = [moment().year(), moment().month()+1, moment().date()]
      return moment(fullDay)
    },
    getStamp: function (data) {
      data = JSON.parse( data )
      return moment(data)
    },
    isDiff: function(data) {
      let a = this.momentNow()
      data = JSON.parse( data )
      let b = moment(data)
      // console.log(data)
      return a.diff(b) <= 0 
    },
    scrollBottom: function () {
      setTimeout(()=>{
        window.scrollTo(0, $('#calendar-content').scrollHeight)
      },0)
    },
    scrollTop: function () {
      setTimeout(()=>{
        window.scrollTo(0, 0)
      },0)
    },
    alert: function (msg) {
      this.alertShow = true
      this.alertMsg = msg
    },
    onAlertConfirm: function() {
        this.alertShow = false
    },
    _clearTaped: function (el) {
      if (el.classList.contains('begin')) {
        el.classList.remove('begin')
        this.dateBegin = null
      } else {
        el.classList.remove('end')
        this.dateEnd = null
      }
    },
    onTap: function (e) {
      let el = e.target
      let elDate = JSON.parse(el.dataset.date)
      let elClass = el.classList
      
      if (elClass.contains('taped')) { //当前日期已点选，清除设置
        el.classList.remove("taped")
        this._clearTaped(el)
        return
      }
      if (!this.dateBegin) {  //开始日期未点选，本次点选设置开始日期
        elClass.add('begin')
        this.dateBegin = elDate
      } else if (!this.dateEnd) { //结束日期未点选
        elClass.add('end')
        this.dateEnd = elDate
      } else { //开始日期，结束日期均已设置，本次设置结束日期
        $('.end').classList.remove('taped')
        $('.end').classList.remove('end')
        elClass.add('end')
        this.dateEnd = elDate
      }
      let momentBegin = moment(this.dateBegin)
      let momentEnd = moment(this.dateEnd)
      if (momentEnd.diff(momentBegin, 'days')<0) {
        // this.alert('结束日期不能早于开始日期')
        // this._clearTaped(el)
        let elBegin = $('.begin')
        let elEnd = $('.end')
        elBegin.classList.remove('begin')
        elBegin.classList.add('end')
        elEnd.classList.remove('end')
        elEnd.classList.add('begin')
        let tmp = this.dateBegin
        this.dateBegin = this.dateEnd
        this.dateEnd = tmp
      }
      this.startTime = this.dateBegin
      this.endTime = this.dateEnd
      elClass.add('taped')
      if (this.dateBegin && this.dateEnd) {

        setTimeout(()=>{
           this.showSwitch = false
           
        },1000)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
#calendar {
  background-color: #f2f2f2;
  z-index: 1000;
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
}
#calendar-content {
  margin-top: 7rem;
}
.month {
  height: 2.8rem;
  line-height: 2.8rem;
  margin-bottom: 2px;
  font-family: PingFangSC-Regular;
  font-size: 1.5rem;
  text-align: center;
  color: #404040;
}
.dates {
  width: 100%;
  height: 100%;
  padding-top: 2rem;
  display: block;
  background-color: #fff;
  &.header {
    position: fixed;
    top: 4rem;
    height: auto;
    z-index: 11;
    padding-top: 0;
    .date {
      height: 3rem;
      line-height: 3rem;
    }
  }
  .date {
    display: block;
    float: left;
    width: 14.2%;
    height: 4rem;
    text-align: center;
    line-height: 2.1rem;
    font-family: PingFangSC-Semibold;
    font-size: 1.4rem;
    /*font-weight: bold;*/
    color: #404040;
    position: relative;
    z-index: 10;
    /*点击样式*/
    &.taped {
      background-color: #17A2FD;
      color: #fff!important;
      &::before {
        font-size: 1.1rem;
        position: absolute;
        z-index: 10;
        width: 100%;
        height: 2rem;
        line-height: 2rem;
        text-align: center;
        bottom: 0rem;
        left: 0rem;
      }
      &.begin {
        border-radius: .5rem 0 0 .5rem;
      }
      &.end {
        border-radius: 0 .5rem .5rem 0;
      }
      &.begin::before {
        content: "开始";
      }
      &.end::before {
        content: '结束';
      }
    }
    &:nth-child(7n),
    &:nth-child(7n+1) {
      color: #F6B150;
    }
    /*过去的日子*/
    &.pass-times {
      color: #C5C5C5;
      &:nth-child(7n),
      &:nth-child(7n+1) {
        color: rgba(127,159,183,0.82);
      }
    }
    /*today样式*/
    &.current {
      color: #17A2FD;
      &:nth-child(7n),
      &:nth-child(7n+1) {
        color: #17A2FD;
      }
    }
    /*选中样式*/
    &.select {
      color: #17A2FD;
      background: #D1E5FE;
      opacity: 0.5;
      &:nth-child(7n),
      &:nth-child(7n+1) {
        color: #17A2FD;
        background: #D1E5FE;
        opacity: 0.5;
      }
    }
  }
}
</style>
