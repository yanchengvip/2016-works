<template>
    <header :class="{ fixed: config.fixed || true, back: config.back || false, headertitle: config.title, absolute: config.positionAbsolute || false}">
        <a href="{{config.link || 'javascript:history.back();'}}" v-if="config.back" id="back">
            <i class="icon">&#xe604;</i>
        </a>
        <div class="tabs" v-if="typeof config.tabs == 'object'">
            <a v-link="{path: tab.link}" class="tab" :class='{active: tab.active}' @click="switchTab(index)" v-for="(index, tab) in config.tabs">{{ tab.name }}</a>
        </div>
        <span v-else>{{ config.title }}</span>
        <div class="history-icon right" v-if="!config.title" v-link="{ path: '/task/history' }"></div>
    </header>
</template>

<script>
export default {
    props: {
        config: {
            default: function () {
                return {
                    link: 'javascript:history.back();',
                    fixed: true
                }
            }
        }
    },
    ready: function () {
    },
    methods: {
        switchTab: function (index) {
            this.config.tabs[index].active = true
            let otherIndex = Math.abs(index-1)
            this.config.tabs[otherIndex].active = false
        }
    }

}
</script>



<style lang="scss" scoped>
@import '../../styles/variable.scss';
header {
    height: 4rem;
    background-color: $main-color;
    text-align: center;
    color: #fff;
    line-height: 4rem;
    font-size: 1.5rem;
    position: relative;
    width: 100%;
    z-index: 100;
    box-shadow:0px 1px 0px 0px #c0c0c0;
    &.headertitle.back {
        background-color: #FFF;
        color: $title-color;
    }
    #back {
        display: block;
        position: absolute;
        left: 0rem;
        top: 0rem;
        height: 4rem;
        width: 4rem;
        text-align: center;
        i {
            font-size: 2.5rem;
            color: $main-color;
        }
    }
    img {
        display: block;
        height: 2.2rem;
        margin-left: 1rem;
    }
    &.red {
        color: #fff;
        background-color: #e62e46;
    }
    &.fixed {
        position: fixed;
        top: 0;
        left: 0;
        &.absolute {
          position: absolute;
        }
    }
    .history-icon {
        width: 2rem;
        height: 2rem;
        background-image: url(../../assets/base/history-icon.png);
        background-repeat: no-repeat;
        background-size: 100% 100%;
        background-position: center center;
    }
}

.right {
    position: absolute;
    right: 1.2rem;
    top: 50%;
    margin-top: -1rem;
    line-height: 4rem;

}
.tabs {
    .tab {
        display: inline-block;
        font-size: 1.2rem;
        width: 6rem;
        border: 1px solid #fff;
        height: 2.5rem;
        line-height: 2.5rem;
        color: #fff;
        text-align: center;
        &:first-child {
            border-top-left-radius: 2rem;
            border-bottom-left-radius: 2rem;
            border-right: 0;
        }
        &:last-child {
            border-top-right-radius: 2rem;
            border-bottom-right-radius: 2rem;
        }
        &.active {
            background-color: #fff;
            color: $main-color;
        }
    }
}
</style>
