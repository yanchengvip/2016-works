<template>
  <page-header :config='headerConfig'></page-header>
  <main class="panel">
    <div class="f26 title">亲爱的用户还有不清楚的地方可以直接致电我们的美女客服哦。</div>
    <div class="f26"><span>服务时间：</span>09:00 - 18:00</div>
    <div class="f26"><span>公司地址：</span>北京市东城区张旺胡同17号</div>
    <div class="f26"><span>公司电话：</span><a class="link" href="tel:010-57745342">010-58349228</a></div>
    <div class="f26"><span>客服邮箱：</span><a href="mailto:jinhuotuan@davidchoice.com">jinhuotuan@davidchoice.com</a></div>
  </main>
</template>
<script>

export default {
  data () {
    return {
      headerConfig: {
        title: "联系客服",
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
    &.title {
      color: #3C3C3C;
    }
    padding: 1rem 0 .5rem 0;
    color: #606060;
    span {
      font-size: 1.2rem;
      font-weight: 600;
      color: #404040;
    }
    a {
      font-size: 1.1rem;
      color: #17a2fd;
    }
  }
  .link {
    font-size: 1.2rem;
  }
</style>