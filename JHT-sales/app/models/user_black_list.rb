class UserBlackList < ActiveRecord::Base
  self.table_name = 'userblacklists'
  belongs_to :user
  include UUIDHelper
end