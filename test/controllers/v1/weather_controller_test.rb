require "test_helper"
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class V1::WeatherControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.clear
  end

  test "should return JSON weather data" do
    city = "Melbourne"
    country = "AU"

    get v1_weather_url(city: city, country: country)
    assert_response :success
    assert_equal "application/json; charset=utf-8", @response.content_type
    json = JSON.parse(@response.body)
    assert json.key?("wind_speed"), "Response should include 'wind_speed'"
    assert json.key?("temperature_degrees"), "Response should include 'temperature_degrees'"
  end

  test "should cache weather data" do
    city = "Melbourne"
    country = "AU"
    cache_key = "weather:#{city}"

    Rails.cache.delete(cache_key)
    assert_nil Rails.cache.read(cache_key), "Cache should be empty before request"
    get v1_weather_url(city: city, country: country)
    assert_response :success
    cached = Rails.cache.read(cache_key)
    assert_not_nil cached, "Weather data should be cached after first request"
    get v1_weather_url(city: city, country: country)
    assert_response :success
    cached_again = Rails.cache.read(cache_key)
    assert_equal cached, cached_again, "Cache should return the same weather data"
  end
end
