<template>
  <page-header :config='headerConfig'></page-header>
  <main class="panel">
    <div class="f26"><span>收入构成</span></div>
    <div class="f24">每周收入由两部分组成：商品收入和奖励</div>
    <div class="f24">1、商品收入 = 商品价格 × 商品收入系数 × 实际收款商品数量</div>
    <!-- <div class="f24">商品收入系数————<a v-link="{path: '/products/list'}" class="link">《点击查看》</a></div> -->
    <div class="f24">2、奖励 = 本周商品收入 + 等级奖励</div>
    <!-- <div class="f24">等级奖励规则————<a v-link="{path: '/task'}" class="link">《点击查看》</a></div> -->
    <div class="f24">商品收入计算以当周实际收款的订单金额为计算基数。本周未付货款的订单不计入计算基数。若订单于次周完成收货，相应的收入会计入下一周收入。</div>

    <div class="f26"><span>收入结算</span></div>
    <div class="f24">当周收入会在第二周周四下午5点前由第三方统一发至注册人的银行卡中。</div>

    <div class="f26"><span class="main-red">注意事项</span></div>
    <div class="f24">1、商品收入比率不是固定的，会随着各商品的销售情况有所浮动，适用比率以下单时的比率为准，详细请查看订单明细。</div>
    <div class="f24">2、奖励的等级根据当周订单实收金额来计算。第二周等级从0级开始，根据战绩重新累计。每周的统计周期为周一00：00到周日晚12：00。</div>
    <div class="f24">3、获得奖金，需要同时满足以下要求：</div>
    <div class="f24">&nbsp;&nbsp;当周促成的交易用户（收款用户）数大于等于5个</div>
    <div class="f24">&nbsp;&nbsp;退货率小于等于2% </div>
    <div class="f24">（退货率 = 本周退货商品总金额 / 本周成交总金额 ）</div>
    <div class="f24">4、商品收入部分没有交易用户数量要求。</div>
    <p></p>
    <p></p>
    <p></p>
  </main>
</template>
<script>

export default {
  data () {
    return {
      headerConfig: {
        title: "查看规则",
        back: true
      },
    }
  },
  ready: function () {
    
  }
}
</script>
<style lang="scss" scoped>
  .panel {
    background: #fff;
    padding-top: 0;
    margin-top: 1rem;
    padding-bottom: .6rem;
    padding-left: 2rem;
  }
  .f26 {
    padding: 1rem 0 .5rem 0;
    color: #606060;
    &.title {
      color: #3C3C3C;
    }
    span {
      font-size: 1.2rem;
      font-weight: 600;
      color: #404040;
      &.main-red {
        color: #ec4d2d;
      }
    }
  }
  .f24 {
    color: #404040;
  }
  .link {
    font-size: 1.2rem;
  }
</style>