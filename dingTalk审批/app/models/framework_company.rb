# 公司表
class FrameworkCompany < ActiveRecord::Base
  self.table_name = 'frameworkcompanies'
  has_many :purchases,foreign_key: 'CompanyID'
  has_many :products, foreign_key: 'CompanyID'
end