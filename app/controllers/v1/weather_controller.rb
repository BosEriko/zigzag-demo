require 'net/http'
require 'uri'
require 'json'

class V1::WeatherController < ApplicationController
  CACHE_TTL = 3.seconds

  def show
    city = params[:city].to_s.strip
    # country included for openweather fallback
    country = params[:country].to_s.strip
    country = "AU" if country.empty?

    if city.empty?
      render json: { error: "Weather unavailable" }
      return
    end

    weather = Rails.cache.fetch("weather:#{city}", expires_in: CACHE_TTL) do
      fetch_weather_with_fallback(city, country)
    end

    render json: weather
  end

  private

    def fetch_weather_with_fallback(city, country)
      fetch_weather_from_weatherstack(city)
    rescue
      fetch_weather_from_openweathermap(city, country)
    rescue => e
      Rails.cache.read("weather:#{city}") || { error: "Weather unavailable" }
    end

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

    def fetch_weather_from_openweathermap(city, country)
      uri = URI("https://api.openweathermap.org/data/2.5/weather?q=#{city},#{country}&units=metric&appid=2326504fb9b100bee21400190e4dbe6d")

      # Conditional is needed to request to HTTPS on localhsot
      if Rails.env.development?
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 5

        response = http.get(uri.request_uri)
        data = JSON.parse(response.body)
      else
        response = Net::HTTP.get(uri)
        data = JSON.parse(response)
      end

      {
        wind_speed: data.dig('wind', 'speed'),
        temperature_degrees: data.dig('main', 'temp')
      }
    end
end
