<template>
    <div class="address-select-group">
      <select v-model="value.provinceId" :class='{ selected: value.provinceId}'>
        <option value=0>请选择省</option>
        <option value="{{ p.value }}" v-for="p in provinces">{{ p.name }}</option>
      </select>
      <select v-model="value.cityId" :class='{ selected: value.cityId}'>
        <option value=0>请选择市</option>
        <option value="{{ c.value }}" v-for="c in cities">{{ c.name }}</option>
      </select>
      <select v-model="value.districtId" :class='{ selected: value.districtId}'>
        <option value=0>请选择区</option>
        <option value="{{ d.value }}" v-for="d in districts">{{ d.name }}</option>
      </select>
    </div>
</template>

<script>
// import Data from './list.json'
export default {
    props: {
        value: {
            type: Object
        },
        loading: {
            required: false
        },
        data: {
          required: false,
          default: function () {
            return []
          }
        }
    },
    ready: function () {
      this.getCities()
    },
    methods: {
        getCities: function () {
            var list = []
            var self = this
            this.loading = true
            Vue.http.get('/cities.json').then((o)=> {
              this.loading = false;
              let data = o.json()
              for (var index = data.data.length - 1; index >= 0; index--) {
                var i = data.data[index]
                var pId = i.provinceID
                list.push({
                  name: i.provinceName,
                  value: pId
                })
                for (var index2 = i.city.length - 1; index2 >= 0; index2--) {
                  var j = i.city[index2]
                  var cId = j.cityID
                  list.push({
                    name: j.cityName,
                    value: cId,
                    parent: pId
                  })
                  for (var index3 = j.county.length - 1; index3 >= 0; index3--) {
                    var k = j.county[index3]
                    list.push({
                      name: k.countyName,
                      value: k.countyID,
                      parent: cId
                    })
                  }
                }
              }
              this.data = list
            })
        }
    },
    watch: {
        "value.provinceId": function (newVal, oldVal) {
            this.value.cityId = 0
            this.value.districtId = 0
        },
        "value.cityId": function (newVal, oldVal) {
            this.value.districtId = 0
        }
    },
    computed: {
        provinces: function () {
            return _.filter(this.data, (o)=> {
                return !o.parent
            })
        },
        cities: function () {
            let provinceId = this.value.provinceId
            return _.filter(this.data, (o)=> {
                return o.parent == provinceId
            })
        },
        districts: function () {
            let cityId = this.value.cityId
            return _.filter(this.data, (o)=> {
                return o.parent == cityId
            })
        }
    }
}
</script>



<style lang="scss" scoped>
@import '../../styles/variable.scss';
.address-select-group {
    select {
        height: 100%;
        line-height: 100%;
        font-size: 1rem;
        max-width: 10rem;
        text-align: center;
        color: $light-text-color;
        &.selected {
            color: $text-color;
        }
    }
}
</style>
