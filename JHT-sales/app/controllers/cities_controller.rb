class CitiesController < ApplicationController
  skip_before_action  :verify_authenticity_token


  def show
    @provinces = Province.all
    @cities  = City.includes(:counties,:province).where(IsEnabled:true).all
  end


  def show_city
    @provinces = Province.all
    @cities  = City.includes(:province).where(IsEnabled:true).all
  end

end