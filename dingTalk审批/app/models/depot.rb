class Depot < ActiveRecord::Base
  self.table_name = 'depots'
  has_many :purchases, foreign_key: 'DepotID'

end