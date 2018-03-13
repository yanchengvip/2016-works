class UserRelation < ActiveRecord::Base
  self.table_name = 'userrelations'
  belongs_to :user,foreign_key: 'UserID'
  include UUIDHelper
  before_create :create_time
  validates :UserID,presence: true
  validates :RelationUserID,presence: true,uniqueness: true



  private


  def create_time
    self.CreateTime = Time.now
    self.UpdateTime = Time.now
  end
end