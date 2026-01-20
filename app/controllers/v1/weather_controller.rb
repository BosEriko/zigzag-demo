require 'net/http'
require 'uri'
require 'json'

class V1::WeatherController < ApplicationController
  def show
    city = params[:city]
    uri = URI("http://api.weatherstack.com/current?access_key=#{ENV['WEATHERSTACK_KEY']}&query=#{city}")
    response = Net::HTTP.get(uri)

    weather_data = JSON.parse(response)

    render json: {
      wind_speed: weather_data['current']['wind_speed'],
      temperature_degrees: weather_data['current']['temperature']
    }
  end
end
