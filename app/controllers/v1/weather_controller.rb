require 'net/http'
require 'uri'
require 'json'

class V1::WeatherController < ApplicationController
  CACHE_TTL = 3.minutes

  def show
    city = params[:city].to_s.downcase

    weather = Rails.cache.fetch("weather:#{city}", expires_in: CACHE_TTL) do
      begin
        fetch_weather_from_weatherstack(city)
      rescue
        fetch_weather_from_openweathermap(city)
      end
    end

    render json: weather
  end

  private

    def fetch_weather_from_weatherstack(city)
      uri = URI("http://api.weatherstack.com/current?access_key=#{ENV['WEATHERSTACK_KEY']}&query=#{city}")

      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      raise "Weatherstack error" if data['error']

      {
        wind_speed: data.dig('current', 'wind_speed'),
        temperature_degrees: data.dig('current', 'temperature')
      }
    end

    def fetch_weather_from_openweathermap(city)
      uri = URI("https://api.openweathermap.org/data/2.5/weather?q=#{city}&units=metric&appid=2326504fb9b100bee21400190e4dbe6d")

      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      {
        wind_speed: data.dig('wind', 'speed'),
        temperature_degrees: data.dig('main', 'temp')
      }
    end
end
