json.extract! course, :id, :title, :name, :city_id, :start_course, :created_at, :updated_at
json.url course_url(course, format: :json)
