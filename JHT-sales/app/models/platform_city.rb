class PlatformCity < ActiveRecord::Base
  self.table_name = 'platform_cities'

  belongs_to :city, :foreign_key => "CityID"


end