class BankInfoesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def bank_query
    @banks = BankInfo.where("DataLevel = 1 and Sort > 0 and Sort != 1000").order("Sort")
    render json:@banks
  end

  # 分行查询
  def bank_branch
    @result = BankInfo.where(ParentID: params[:id]).order("convert(Name USING GBK)")
    render json:@result
  end
end
