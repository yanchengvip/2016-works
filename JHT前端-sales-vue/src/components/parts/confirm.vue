<template>
    <div id="show-dialog" v-show="show">
        <div id="msg-box">
            <div class="caption">
                <slot></slot>
            </div>
            <div class="buttom-group pure-g">
                <template v-if="!alert">
                    <a class="pure-u-1-2" href="javascript:;" @click="cancel">{{ cancelText }}</a>
                    <a class="pure-u-1-2 main-color" href="javascript:;" @click="confirm">{{ confirmText }}</a>
                </template>
                <a v-else class="pure-u-1 main-color" href="javascript:;" @click="cancel">{{ confirmText }}</a>
            </div>
        </div>
    </div>
</template>

<script>
export default {
  props: {
    'alert': {
        default: false
    },
    'cancel-text': {
        default: '取消'
    },
    'confirm-text': {
        default: '确定'
    },
    'onCancel': {
        required: false,
        default: false
    },
    'onConfirm': {
        required: false,
        default: false
    },
    'show': {
        required: true
    }
  },
  methods: {
    'cancel': function () {
        if (this.onCancel) {
            this.onCancel()
        } else {
            this.show = false
        }
    },
    'confirm': function () {
        if (this.onConfirm) {
            this.onConfirm()
        } else {
            this.show = false
        }
    }
  },
  ready: function () {
  },
  watch: {
  }
}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';

#show-dialog {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 20000;
    background-color: rgba(40, 40, 40, .8);
    #msg-box {
        width: 25rem;
        position: absolute;
        top: 50%;
        margin-top: -11rem;
        left: 50%;
        margin-left: -12.5rem;
        background-color: #fff;
        border-radius: .5rem;
        .caption {
            border-bottom: 1px solid #e0e0e0;
            font-size: 1.6rem;
            line-height: 1.3;
            padding: 2rem 2.1rem 1.35rem 2.1rem;
            text-align: center;
            color: $text-color;
        }
        .buttom-group {
            a {
                display: block;
                text-align: center;
                height: 4.5rem;
                line-height: 4.5rem;
                font-size: 1.5rem;
                color: #404040;
                &:first-child {
                    color: #909090;
                    border-right: 1px solid #e0e0e0;
                }
            }
        }
    }
}
</style>
