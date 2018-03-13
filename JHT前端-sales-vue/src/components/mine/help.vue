<template>
  <page-header :config='headerConfig'></page-header>
  <main class="panel">
    <div class="f26"><span>认证需要多久？</span></div>
    <div class="f26">第三方意向签署后，通常在1个工作日内确认。</div>
    <div class="f26"><span>平台收入何时结算？</span></div>
    <div class="f26">&nbsp;&nbsp;任务结束后，经核查无误，会由进货团成员所属第三方合作机构支付。收入直接打到业务员注册账户的银行卡。</div>
    <div class="f26"><span>哪些行为属于平台禁止行为？</span></div>
    <div class="f26">1. 业务员直接代司机收取进货款</div>
    <div class="f26">2. 销售产品到批发市场和二级批发市场等批发渠道客户</div>
    <div class="f26">3. 刷单等涉嫌欺诈的行为</div>
    <div class="f26">&nbsp;&nbsp;如果出现以上违规行为，第三方会终止发放未发放收入，同时平台永不接受该人员再次注册使用。</div>
  </main>
</template>
<script>

export default {
  data () {
    return {
      headerConfig: {
        title: "使用帮助",
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
    margin-top: 1rem;
    padding:0 2rem .6rem 2rem;
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