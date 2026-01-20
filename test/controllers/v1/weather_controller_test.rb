require "test_helper"

class V1::WeatherControllerTest < ActionDispatch::IntegrationTest
  test "should return JSON weather data" do
    city = "Melbourne"
    country = "AU"

    get v1_weather_url(city: city, country: country)
    assert_response :success
    assert_equal "application/json; charset=utf-8", @response.content_type
    json = JSON.parse(@response.body)
    assert json.key?("wind_speed")
    assert json.key?("temperature_degrees")
  end
end
