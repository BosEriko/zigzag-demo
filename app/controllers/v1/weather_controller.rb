require 'net/http'
require 'uri'
require 'json'

class V1::WeatherController < ApplicationController
  CACHE_TTL = 3.minutes

  def show
    city = params[:city].to_s.downcase

    weather = Rails.cache.fetch(weatherstack: "#{city}", expires_in: CACHE_TTL) do
      fetch_weather_from_weatherstack(city)
    end

    render json: weather
  end

  private

    def fetch_weather_from_weatherstack(city)
      uri = URI("http://api.weatherstack.com/current?access_key=#{ENV['WEATHERSTACK_KEY']}&query=#{city}")

      response = Net::HTTP.get(uri)
      weather_data = JSON.parse(response)

      {
        wind_speed: weather_data.dig('current', 'wind_speed'),
        temperature_degrees: weather_data.dig('current', 'temperature')
      }
    end
end
