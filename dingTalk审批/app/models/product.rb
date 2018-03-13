# == Schema Information
#
# Table name: Products
#
#  ID               :string(36)       default(""), not null, primary key
#  Name             :string(100)      default(""), not null
#  Code             :string(100)      default(""), not null
#  Slogan           :string(255)
#  State            :integer
#  OrderBy          :integer
#  Tag              :integer
#  ProductGroupsID  :string(36)
#  Show             :text(4294967295)
#  Recommend        :integer
#  Describe         :text(4294967295)
#  Specification    :string(255)
#  ProductPrice     :decimal(18, 4)
#  Unit             :string(255)
#  Weight           :integer
#  PhotoID          :string(36)
#  ServicePoint     :decimal(18, 2)
#  CreateTime       :datetime
#  CreateBy         :string(100)
#  UpdateTime       :datetime
#  UpdateBy         :string(100)
#  HtmlShow         :text(4294967295)
#  OriginalPrice    :decimal(18, 4)
#  ProductBrandName :string(255)
#  PurchasePrice    :decimal(18, 4)
#  Cover            :string(255)
#  CoverQiniu       :string(255)
#

# State： 1=已下架,2=未下架
class Product < ActiveRecord::Base
  self.table_name = 'Products'

  belongs_to :product_info, :foreign_key => "ProductInfoID"
  has_many :product_prices,foreign_key: 'ProductID'
  belongs_to :framework_company,:foreign_key => 'CompanyID'
  def cover_url version=nil
    product_info.cover_url(version)
  end




end
