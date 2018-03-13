json.status 'ok'
json.data do
   @provinces.each do |province|
    json.city do
      json.array! @cities.each do |city|
        if city.ProvinceID ==   province.ID
          json.provinceID    province.ID
          json.cityID city.ID
          json.cityName city.CityName
          json.image_url Settings.qiniu.qiniu_base_url + city.LogoQiNiu.to_s
        end
      end

    end

  end


end