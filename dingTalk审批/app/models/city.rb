# == Schema Information
#
# Table name: Cities
#
#  ID         :string(36)       default(""), not null, primary key
#  CityCode   :string(255)      not null
#  CityName   :string(255)      not null
#  ProvinceID :string(36)
#  CreateTime :datetime
#  CreateBy   :string(100)
#  UpdateTime :datetime
#  UpdateBy   :string(100)
#

class City < ActiveRecord::Base
  self.table_name = 'Cities'

  belongs_to :province, :foreign_key => "ProvinceID"
  has_many :counties, ->{order("CountyCode")}, :foreign_key => "CityID"


end
