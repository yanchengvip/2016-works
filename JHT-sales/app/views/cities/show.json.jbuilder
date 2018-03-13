json.status 'ok'
json.data do
  json.array! @provinces.each do |province|
    json.provinceID    province.ID
    json.provinceName province.ProvinceName
    json.city do
        json.array! @cities.each do |city|
          if city.ProvinceID ==   province.ID
              json.cityID city.ID
              json.cityName city.CityName
              json.image_url Settings.qiniu.qiniu_base_url + city.LogoQiNiu.to_s
            json.county do
              json.array! city.counties do |county|
                json.countyID county.ID
                json.countyName county.CountyName
              end

            end
          end
        end

    end

  end


end