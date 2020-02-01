class Course < ApplicationRecord
  require 'net/http'

  belongs_to :city
  has_many :sessions, dependent: :destroy

  validates :name, :description, :start_course, :city_id, presence: true

  validate :cant_start_a_weekend

  after_create :create_sessions

  def cant_start_a_weekend
    if start_course.wday == 5 || start_course.wday == 6 || start_course.wday == 0
      errors.add(:start_course, "can't start a weekend or friday") 
    end   
  end

  def create_sessions
    # Lunes y miercoles
    # Martes y jueves
    start_day = start_course.wday 
    position = 1
    arr = []
    arr << start_day
    start = start_course.to_date
    hour = start_course.strftime("%H").to_i
    min = start_course.strftime("%M").to_i

    (start..start+ 5.weeks).to_a.each do |date|
      if arr.last == date.wday && position <= 8
        date = date.to_datetime.change(min: min, hour: hour)
        self.sessions.create(position_session: position, start_session: date)
        arr = case_of_day(arr)
        position += 1
      end
    end
    
  end

  def case_of_day(arr)
    case arr.last
    when 1
      arr << 3
    when 2
      arr << 4
    when 3
      arr << 1
    when 4  
      arr << 2    
    end 
  end


  def weather
    uri_key = "http://dataservice.accuweather.com/locations/v1/cities/search?apikey=0yP6TCThGY2O7GD6dlaygygjm5mn3rT3&q=#{self.city.name}"
    res_key = get_accuweather(uri_key) 
    get_key = res_key[0]["Key"].to_i
    
    uri_forecast_weather = "http://dataservice.accuweather.com/forecasts/v1/daily/5day/#{get_key}?apikey=0yP6TCThGY2O7GD6dlaygygjm5mn3rT3"

    res_forecast_weather = get_accuweather(uri_forecast_weather)
    
    today = res_forecast_weather["DailyForecasts"][0]["Temperature"]['Maximum']['Value']
    tomorrow = res_forecast_weather["DailyForecasts"][1]["Temperature"]['Maximum']['Value']
    temperature = "La temperatura maxima de hoy es: #{ ((today - 32) / 1.8).round(2) } - La temperatura maxima mañana es: #{ ((tomorrow - 32) / 1.8).round(2) } "
    
  end

  def get_accuweather(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    body = res.body if res.is_a?(Net::HTTPSuccess)
    parse = JSON.parse(body)
    parse
  end

  
end
