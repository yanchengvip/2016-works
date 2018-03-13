<template>
	<swiper id="app" v-ref:swiper
        direction="vertical"
        :mousewheel-control="true"
        :performance-mode="false"
        :pagination-clickable="true"
        @slide-change-start="onSlideChangeStart"
        @slide-change-end="onSlideChangeEnd">
    <div class="slider p1">
    	<div class="layer">
    		<div class="l1"></div>
    		<div class="l2"></div>
    		<div class="l3"></div>
    	</div>
    </div>
    <div class="slider p2">
    	<div class="layer">
    		<div class="l1"></div>
    		<div class="l2"></div>
    		<div class="l3"></div>
    		<div class="l4"></div>
    	</div>
    </div>
    <div class="slider p3">
    	<div class="layer">
    		<div class="l1"></div>
    		<div class="l2"></div>
    		<div class="l3"></div>
    		<div class="l4"></div>
    		<div class="l5"></div>
    	</div>
    </div>
    <div class="slider p4">
    	<div class="layer">
    		<div class="l1"></div>
    		<div class="l2"></div>
    		<div class="l3"></div>
    		<div class="l4"></div>
    		<div class="l5"></div>
    		<div class="l6"></div>
    	</div>
    </div>
    <div class="slider p5">
    	<div class="layer">
    		<div class="l1"></div>
    		<div class="l2">
    			<div class="phone-number">
    				{{ name }}:<a href="tel:{{ mobile }}">{{ mobile }}</a>
    			</div>
    		</div>
    		<div class="l3"></div>
    		<div class="l4"></div>
    		<div class="l5"></div>
    		<div class="l6"></div>
    		<!-- <div class="l7">
    			<img src="../../assets/activity/share_page/qrcode.jpg" alt="">
    		</div> -->
    	</div>
    </div>
	</swiper>
	<div class="music-play" :class="{no: !onOff}" @click = "musicPlay()">
		<audio id="ids" loop="loop" preload="preload">
      <source src="http://7xp1gb.media1.z0.glb.clouddn.com/bg.mp3" type="audio/mp3" />
    </audio>
	</div>
</template>
	
<script>
	import Swiper from 'vue-swiper'
	export default {
		data () {
			return {
				name: '',
				mobile: '',
				onOff: true
			}
		},
		methods: {
			nodeListToArr: function(nodes) {
				var arr;
				try {
					arr = [].slice.call(nodes)
					return arr
				} catch (err) {
					arr = [];
					for (var i = 0; i < nodes.length; i++) {
						arr.push(nodes[i])
					}
					return arr
				}
			},
			getRequest: function() {
				var url = location.hash
				var _index = url.indexOf('?')
				url = url.substr(_index)
				// var url = 'http://192.168.44.4:8080/#!/activity/share_page/?name=lpt&mobile=15210256910'
				var obj = {}
				if (url.indexOf('?') != -1) {
					var str = url.substr(1)
					var strs = str.split('&')
					for (var i = 0; i < strs.length; i++) {
						obj[strs[i].split('=')[0]] = decodeURIComponent(strs[i].split("=")[1])
					}
				}
				return obj 
			},
			musicPlay: function() {
					let elem = document.getElementsByTagName('audio')[0]
					if(this.onOff) {
						elem.pause()
						this.onOff = false
						$('.music-play').classList.add('no')
					} else {
						elem.play()
						this.onOff = true
						$('.music-play').classList.remove('no')
					}
			},
			onSlideChangeStart (currentPage) {
				var els = document.querySelectorAll('.move')
				_.map(els,function(item,index) {
					item.classList.remove('move')
				})
				if (currentPage == 3) {
      		$('.p3 .l1').classList.add('move')
      		$('.p3 .l2').classList.add('move')
      		$('.p3 .l3').classList.add('move')
      		$('.p3 .l4').classList.add('move')
      		$('.p3 .l5').classList.add('move')
      	}
				// els.classList.remove('move')
      },
      onSlideChangeEnd (currentPage) {
      	// var pageItem = '.p' + currentPage
      	if (currentPage == 1) {
      		$('.p1 .l1').classList.add('move')
      		$('.p1 .l2').classList.add('move')
      		$('.p1 .l3').classList.add('move')
      	}
      	if (currentPage == 2) {
      		$('.p2 .l1').classList.add('move')
      		$('.p2 .l2').classList.add('move')
      		$('.p2 .l3').classList.add('move')
      		$('.p2 .l4').classList.add('move')
      	}
      	// if (currentPage == 3) {
      	// 	$('.p3 .l1').classList.add('move')
      	// 	$('.p3 .l2').classList.add('move')
      	// 	$('.p3 .l3').classList.add('move')
      	// 	$('.p3 .l4').classList.add('move')
      	// 	$('.p3 .l5').classList.add('move')
      	// }
      	if (currentPage == 4) {
      		$('.p4 .l1').classList.add('move')
      		$('.p4 .l2').classList.add('move')
      		$('.p4 .l3').classList.add('move')
      		$('.p4 .l4').classList.add('move')
      		$('.p4 .l5').classList.add('move')
      		$('.p4 .l6').classList.add('move')
      	}
      	if (currentPage == 5) {
      		$('.p5 .l1').classList.add('move')
      		$('.p5 .l2').classList.add('move')
      		$('.p5 .l3').classList.add('move')
      		$('.p5 .l4').classList.add('move')
      		$('.p5 .l5').classList.add('move')
      		$('.p5 .l6').classList.add('move')
      		// $('.p5 .l7').classList.add('move')
      	}
        // console.log('onSlideChangeEnd', currentPage);
      }
		},
		computed: {
		},
		ready: function () {
			this.name = this.getRequest().name
			this.mobile = this.getRequest().mobile
			setTimeout(function(){
				$('.p1 .l1').classList.add('move')
				$('.p1 .l2').classList.add('move')
				$('.p1 .l3').classList.add('move')
			},100)
			$('#ids').play()
			document.title = "进货团,够胆你就来"
		},
		components: {Swiper},
		watch: {
			
		}
	}
</script>

<style lang="scss" scoped>
@import '../../styles/base.scss';
html,
body {
	height: 100% !important;
}
.music-play {
	position: fixed;
	top: 2rem;
	right: 2rem;
	width: 3rem;
	height: 3rem;
	background: url('../../assets/activity/share_page/on.png') no-repeat center center;
	background-size: 100% 100%;
	&.no {
		background: url('../../assets/activity/share_page/off.png') no-repeat center center;
		background-size: 100% 100%;
	}
}
#app {
	width: 100%;
	height: 100%;
	overflow: hidden;
	.slider {
		position: relative;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: url('../../../src/assets/activity/share_page/bg.png') no-repeat center center;
		background-size: 100% 100%;
	}
	.layer {
		position: absolute;
		top: 12.4rem;
		width: 100%;
		height: 26.2rem;
		/*text-align: center;*/
		div {
			display: block;
			margin: 0 auto;
		}
	}
	.p1 {
			z-index: 100;
		.l1 {
			width: 28.1rem;
			height: 9.7rem;
			background: url('../../assets/activity/share_page/session_11.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: translateY(-300%);
					-ms-transform: translateY(-300%);
					 -o-transform: translateY(-300%);
							transform: translateY(-300%);
			-webkit-transition: all 1.4s cubic-bezier(0, 2.07, 0.46, 0.29);
					 -o-transition: all 1.4s cubic-bezier(0, 2.07, 0.46, 0.29);
							transition: all 1.4s cubic-bezier(0, 2.07, 0.46, 0.29);
			&.move {
				transform: translateY(0);
			}
		}
		.l2 {
			position: absolute;
			top: 10.2rem;
			left: .5rem;
			width: 16.8rem;
			height: 14.5rem;
			background: url('../../assets/activity/share_page/session_22.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: scale(0);
					-ms-transform: scale(0);
					 -o-transform: scale(0);
							transform: scale(0);
			-webkit-transition: all 1s cubic-bezier(1,-0.49, 0, 2.31) 1.5s;
					 -o-transition: all 1s cubic-bezier(1,-0.49, 0, 2.31) 1.5s;
							transition: all 1s cubic-bezier(1,-0.49, 0, 2.31) 1.5s;
			&.move {
				-webkit-transform: scale(1);
						-ms-transform: scale(1);
						 -o-transform: scale(1);
								transform: scale(1);
			}
		}
		.l3 {
			position: absolute;
			top: 7.2rem;
			right: 0.5rem;
			width: 18.1rem;
			height: 19.5rem;
			background: url('../../assets/activity/share_page/session_33.png') no-repeat center center;
			background-size: 100% 100%;
			-webkit-transform: scale(0);
					-ms-transform: scale(0);
					 -o-transform: scale(0);
							transform: scale(0);
			-webkit-transition: all 1s cubic-bezier(1,-0.49, 0, 2.31) 1.5s;
					 -o-transition: all 1s cubic-bezier(1,-0.49, 0, 2.31) 1.5s;
							transition: all 1s cubic-bezier(1,-0.49, 0, 2.31) 1.5s;
			&.move {
				-webkit-transform: scale(1);
						-ms-transform: scale(1);
						 -o-transform: scale(1);
								transform: scale(1);
			}
		}
	}
	.p2 {
		z-index: 200;
		.l1 {
			width: 24.5rem;
			height: 7.4rem;
			margin-left: 1rem;
			background: url('../../assets/activity/share_page/session_2_top.png') no-repeat center center;
			background-size: 100% 100%;
			-webkit-transform: translateY(-300%);
					-ms-transform: translateY(-300%);
					 -o-transform: translateY(-300%);
							transform: translateY(-300%);
			-webkit-transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
					 -o-transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
							transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
			&.move {
				-webkit-transform: translateY(0);
				-ms-transform: translateY(0);
				-o-transform: translateY(0);
				transform: translateY(0);
			}
		}
		.l2 {
			width: 24.5rem;
			height: 1.8rem;
			background: url('../../assets/activity/share_page/session_2_tip1.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: translateX(-300%);
					-ms-transform: translateX(-300%);
					 -o-transform: translateX(-300%);
							transform: translateX(-300%);
			-webkit-transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
					 -o-transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
							transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
			&.move {
				-webkit-transform: translateX(0);
						-ms-transform: translateX(0);
					 	 -o-transform: translateX(0);
								transform: translateX(0);
			}
		}
		.l3 {
			width: 14rem;
			height: 1.8rem;
			background: url('../../assets/activity/share_page/session_2_tip2.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: translateX(300%);
					-ms-transform: translateX(300%);
					 -o-transform: translateX(300%);
							transform: translateX(300%);
			-webkit-transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
					 -o-transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
							transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
			&.move {
				-webkit-transform: translateX(0);
						-ms-transform: translateX(0);
						 -o-transform: translateX(0);
								transform: translateX(0);
			}
		}
		.l4 {
			width: 24.5rem;
			height: 13.5rem;
			margin-top: 1rem;
			background: url('../../assets/activity/share_page/session_2_text.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: translateY(300%);
					-ms-transform: translateY(300%);
					 -o-transform: translateY(300%);
							transform: translateY(300%);
			-webkit-transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
					 -o-transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
							transition: all 2s cubic-bezier(0, 2.07, 0.46, 0.29);
			&.move {
				-webkit-transform: translateY(0);
						-ms-transform: translateY(0);
						 -o-transform: translateY(0);
								transform: translateY(0);
			}
		}
	}
	.p3 {
		z-index: 300;
		.l1 {
			width: 24.5rem;
			height: 7.4rem;
			margin-left: 1rem;
			background: url('../../assets/activity/share_page/session_2_top.png') no-repeat center center;
			background-size: 100% 100%;
			-webkit-transform: translateY(-300%);
					-ms-transform: translateY(-300%);
					 -o-transform: translateY(-300%);
							transform: translateY(-300%);
			-webkit-transition: all .8s cubic-bezier(0, 0, 1, 0);
					 -o-transition: all .8s cubic-bezier(0, 0, 1, 0);
							transition: all .8s cubic-bezier(0, 0, 1, 0);
			&.move {
				-webkit-transform: translateY(0);
						-ms-transform: translateY(0);
						 -o-transform: translateY(0);
								transform: translateY(0);
			}
		}
		.l2 {
			width: 21.5rem;
			height: 3.4rem;
			margin-top: 1.2rem;
			background: url('../../assets/activity/share_page/keqing.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: translateX(-300%);
					-ms-transform: translateX(-300%);
					 -o-transform: translateX(-300%);
							transform: translateX(-300%);
			-webkit-transition: all 1s ease 1s;
					 -o-transition: all 1s ease 1s;
							transition: all 1s ease 1s;
			&.move {
				-webkit-transform: translateX(0);
						-ms-transform: translateX(0);
						 -o-transform: translateX(0);
								transform: translateX(0);
			}
		}
		.l3 {
			width: 21.5rem;
			height: 3.4rem;
			background: url('../../assets/activity/share_page/xinxi.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: translateX(300%);
					-ms-transform: translateX(300%);
					 -o-transform: translateX(300%);
							transform: translateX(300%);
			-webkit-transition: all 1s ease 1s;
					 -o-transition: all 1s ease 1s;
							transition: all 1s ease 1s;
			&.move {
				-webkit-transform: translateX(0);
						-ms-transform: translateX(0);
						 -o-transform: translateX(0);
								transform: translateX(0);
			}
		}
		.l4 {
			width: 21.5rem;
			height: 3.4rem;
			background: url('../../assets/activity/share_page/renmai.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: translateY(1100%);
					-ms-transform: translateY(1100%);
					 -o-transform: translateY(1100%);
							transform: translateY(1100%);
			-webkit-transition: all 1s ease 1s;
					 -o-transition: all 1s ease 1s;
							transition: all 1s ease 1s;
			&.move {
				-webkit-transform: translateY(0);
						-ms-transform: translateY(0);
						 -o-transform: translateY(0);
								transform: translateY(0);
			}
		}
		.l5 {
			width: 21.5rem;
			height: 3.4rem;
			background: url('../../assets/activity/share_page/dream.png') no-repeat center center;
			background-size: 100% auto;
			-webkit-transform: scale(0);
					-ms-transform: scale(0);
					 -o-transform: scale(0);
							transform: scale(0);
			-webkit-transition: all 1s ease 1s;
					 -o-transition: all 1s ease 1s;
							transition: all 1s ease 1s;
			&.move {
				-webkit-transform: scale(1);
						-ms-transform: scale(1);
						 -o-transform: scale(1);
								transform: scale(1);
			}
		}
	}
	.p4 {
		z-index: 400;
		.layer {
			padding-left: 2rem;
			padding-top: 2.5rem;
			.l1,
			.l2,
			.l3,
			.l4,
			.l5,
			.l6 {
				width: 24.5rem;
				height: 3rem;
				background: url('../../assets/activity/share_page/session_4.png') no-repeat;
				background-size: 100% auto;
			}
			.l1 {
				height: 2.5rem;
				background-position: 0 0;
				-webkit-transform: translateY(-900%);
					-ms-transform: translateY(-900%);
					 -o-transform: translateY(-900%);
							transform: translateY(-900%);
				-webkit-transition: all 1.4s ease;
						 -o-transition: all 1.4s ease;
								transition: all 1.4s ease;
				&.move {
					-webkit-transform: translateY(0);
					-ms-transform: translateY(0);
					-o-transform: translateY(0);
					transform: translateY(0);
				}
			}
			.l2 {
				height: 3.8rem;
				background-position: 0 -2rem;
				-webkit-transform: translateY(-900%);
					-ms-transform: translateY(-900%);
					 -o-transform: translateY(-900%);
							transform: translateY(-900%);
				-webkit-transition: all 1s ease;
						 -o-transition: all 1s ease;
								transition: all 1s ease;
				&.move {
					-webkit-transform: translateY(0);
					-ms-transform: translateY(0);
					-o-transform: translateY(0);
					transform: translateY(0);
				}
			}
			.l3 {
				height: 2.7rem;
				background-position: 0 -5.8rem;
				-webkit-transform: translateY(-900%);
					-ms-transform: translateY(-900%);
					 -o-transform: translateY(-900%);
							transform: translateY(-900%);
				-webkit-transition: all 1s ease;
						 -o-transition: all 1s ease;
								transition: all 1s ease;
				&.move {
					-webkit-transform: translateY(0);
					-ms-transform: translateY(0);
					-o-transform: translateY(0);
					transform: translateY(0);
				}
			}
			.l4 {
				background-position: 0 -8.1rem;
				-webkit-transform: translateY(-1000%);
					-ms-transform: translateY(-1000%);
					 -o-transform: translateY(-1000%);
							transform: translateY(-1000%);
				-webkit-transition: all 1s ease;
						 -o-transition: all 1s ease;
								transition: all 1s ease;
				&.move {
					-webkit-transform: translateY(0);
					-ms-transform: translateY(0);
					-o-transform: translateY(0);
					transform: translateY(0);
				}
			}
			.l5 {
				background-position: 0 -11rem;
				-webkit-transform: translateY(-1000%);
					-ms-transform: translateY(-1000%);
					 -o-transform: translateY(-1000%);
							transform: translateY(-1000%);
				-webkit-transition: all 1s ease;
						 -o-transition: all 1s ease;
								transition: all 1s ease;
				&.move {
					-webkit-transform: translateY(0);
					-ms-transform: translateY(0);
					-o-transform: translateY(0);
					transform: translateY(0);
				}
			}
			.l6 {
				height: 5rem;
				background-position: 0 -14rem;
				-webkit-transform: scale(0);
					-ms-transform: scale(0);
					 -o-transform: scale(0);
							transform: scale(0);
				-webkit-transition: all 1s cubic-bezier(1, 0, 0, 2.31) 1.4s;
						 -o-transition: all 1s cubic-bezier(1, 0, 0, 2.31) 1.4s;
								transition: all 1s cubic-bezier(1, 0, 0, 2.31) 1.4s;
				&.move {
					-webkit-transform: scale(1);
					-ms-transform: scale(1);
					-o-transform: scale(1);
					transform: scale(1);
				}
			}
		}
	}
	.p5 {
		z-index: 500;
		.layer {
			padding-top: 1rem;
			/* margin-top: -5rem; */
			.l1 {
				width: 26rem;
				height: 6rem;
				margin-left: 1rem;
				margin-bottom: 1rem;
				background: url('../../assets/activity/share_page/session_5_1.png') no-repeat left center;
				background-size: auto 6rem;
				-webkit-transform: translateY(-700%);
					-ms-transform: translateY(-700%);
					 -o-transform: translateY(-700%);
							transform: translateY(-700%);
				-webkit-transition: all 1s ease;
						 -o-transition: all 1s ease;
								transition: all 1s ease;
				&.move {
					-webkit-transform: translateY(0);
					-ms-transform: translateY(0);
					-o-transform: translateY(0);
					transform: translateY(0);
				}
			}
			.l2,
			.l3,
			.l4,
			.l5,
			.l6,
			.l7 {
				width: 26rem;
				height: 3rem;
				background: url('../../assets/activity/share_page/session_5.png') no-repeat center center;
				background-size: 100% auto;
				-webkit-transform: translateY(1500%);
					-ms-transform: translateY(1500%);
					 -o-transform: translateY(1500%);
							transform: translateY(1500%);
				-webkit-transition: all 1.5s ease 1s;
						 -o-transition: all 1.5s ease 1s;
								transition: all 1.5s ease 1s;
				&.move {
					-webkit-transform: translateY(0);
					-ms-transform: translateY(0);
					-o-transform: translateY(0);
					transform: translateY(0);
				}
			}
			.l2 {
				position: relative;
				background-position: 0 1rem;
				.phone-number {
					position: absolute;
					bottom: .2rem;
					left: 2.4rem;
					width: 20rem;
					height: 2rem;
					white-space: nowrap;
					text-align: left;
					text-indent: 5px;
					font-size: 1.6rem;
					font-weight: bold;
					letter-spacing: 3px;
					line-height: 2rem;
				}
			}
			.l3 {
				background-position: 0 -1.8rem;
			}
			.l4 {
				background-position: 0 -4.5rem;
			}
			.l5 {
				background-position: 0 -7.6rem;
			}
			.l6 {
				background-position: 0 -10.7rem;
			}
			.l7 {
				width: 14rem;
				height: 14rem;
				margin-top: 1rem;
				img {
					width: 100%;
					height: 100%;
				}
			}
		}
	}
	
}

</style>