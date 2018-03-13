<template>
	<template v-if="showBollen">
		<page-header :config='headerConfig'></page-header>
		<main class="pure-g">
			<div href = "#" class="pure-u-1-3 city-box" @click="selected(city.provinceID, city.cityID)" v-for="city in cities">
				<!-- <img v-show="city.image_url" src="../../assets/mine/city.png" alt=""> -->
				<img :src="city.image_url">
				<div class="city-name" >{{ city.cityName }}</div>
			</div>
		</main>
	</template>
</template>
	
<script>
	export default {
		props: [
			'cityShow'
		],
		data () {
			return {
				headerConfig: {
					title: '城市选择',
					back: true
				},
				showBollen: true,
				msg: {},
				datas: {},
				cities: {}
			}
		},
		components: {

		},
		computed: {
			
		},
		methods: {
			selected: function (provinceId,cityId) {
				console.log(provinceId)
				let data = {
	        // params: {
	          remember_token: window.TOKEN,
	          ProvinceID: provinceId,
	          CityID: cityId,
	          CountyID: ''
	        // }
	      }
	      Vue.http.post('/users/update_address.json',data).then((o)=>{
	      	this.msg = o.json()
	      })
				this.$router.go({
	        path: '/mine'
	      })
			}
		},
		ready: function () {
      Vue.http.get('/cities/show_city.json').then((o)=>{
        this.cities = o.json().data.city
      })
		},
		watch: {
			
		}
	}
</script>

<style lang="scss" scoped>
@import '../../styles/variable.scss';
.city-box {
		margin-top: 2rem;
		text-align: center;
		img {
				width: 7.5rem;
				height: 7.5rem;
				border-radius: 50%;
				border: 1px solid #fff;
		}
		.city-name {
				font-family: PingFangSC-Regular;
				font-size: 1.4rem;
				font-weight: 600;
				color: #404040;
				text-align: center;
				line-height: 2.3rem;
		}
}
</style>