class V1::WeatherController < ApplicationController
  def show
    city = params[:city]
    puts city
    render json: { wind_speed: 20, tempreture_degrees: 29 }
  end
end
