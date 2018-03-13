<!-- 历史任务 -->
<template>
	<page-header :config='headerConfig'></page-header>
	<main>
		<section class="task-item" @click="goTo(item.user_task_id)" v-for="item in items">
			<div class="wrapper">
				<div class="head">
					<div class="cleared-time">
						{{ item.balance_end_time }}结算
					</div>
					<div class="standard" v-if="item.current_step != 0">已达标</div>
					<div class="notStandard" v-if="item.current_step == 0">未达标</div>
				</div>
				<div class="bottom">
					<div class="status">
						<img :src="item.task_logo" alt="">
					</div>
					<div class="detail">
						<p class="name">{{ item.title }}</p>
						<p class="reward">获得奖励：<span class="reward-name">￥{{ item.current_reward }}</span></p>
					</div>
				</div>
			</div>
		</section>
	</main>
</template>
<script>
	export default {
		data () {
			return {
				headerConfig: {
					title: "已结算任务",
					back: true
				},
				items: [],
				num: 1,
				per_page: 30
			}
		},
		computed: {
			// 根据状态值 断定是否达标
			status: function () {
				return this.items.current_step == 0
			}
		},
		methods: {
			goTo: function (id) {
				this.$router.go({
					path: '/task/' + id
				})
			},
			load: function () {
				let data = {
					params: {
						remember_token: window.TOKEN,
						page: this.num,
						per_page: this.per_page,
						status: 1
					}
				}
				Vue.http.get('/tasks/user_tasks.json',data).then( (o) => {
					this.items = o.json().data
				})
			}
		},
		ready: function () {
			this.load()
		}
	}
</script>

<style lang="scss" scoped>
	@import '../../styles/variable.scss';
	main {
		background:#f3f4f5;
	}
	.task-item {
		width: 100%;
		margin-top: 1.4rem;
		background: #fff;
		box-shadow:0px 3px 0px 0px #e0e0e0;
	}
	.wrapper {
		margin: 0 1.2rem;
		.head {
			height: 3.2rem;
			line-height: 3.2rem; 
			border-bottom: 1px solid #e0e0e0;
			font-family:PingFangSC-Regular;
			font-size: 1.2rem;
			.cleared-time {
				float: left;
				color: #606060;
			}
			.standard {
				float: right;
				color:#17a2fd;
			}
			.notStandard {
				float: right;
				color: #ec4d2d;
			}
		}
		.bottom {
			.status {
				vertical-align: middle;
				display: inline-block;
				width: 4.4rem;
				height: 4.4rem;
				margin: .8rem 0;
				border-radius: 50%;
				overflow: hidden;
				background: pink;
				img {
					width: 100%;
					height: 100%;
				}
			}
			.detail {
				vertical-align: middle;
				margin-left: .8rem;
				display: inline-block;
				p {
					font-family:PingFangSC-Regular;
					font-size:1.2rem;
					color:#404040;
					.reward-name {
						color:#ec4d2d;
					}
				}
			}
		}

	}
	
</style>