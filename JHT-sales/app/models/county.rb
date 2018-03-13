=begin
ID
CountyName
CountyCode
CityID
CompanyID
CreateTime
CreateBy
=end

class County < ActiveRecord::Base
  self.table_name = 'counties'
  belongs_to :city, foreign_key: 'CityID'
end