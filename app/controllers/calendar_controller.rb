class CalendarController < ApplicationController
  def index
  end

  def get_event
    require 'date'

    taked_id = []
    taked_courses = current_user.courses_taked.search_by_sem_id(Semester::LAST.id).map{|cs|cs.to_basic_json}
    taked_courses.each do |course|
      taked_id.push(course[:temp_cos_id])
    end

    events = []
    materials = E3Service.getMaterialInfo
    materials.each do |material|
      event = material
      event["TimeStart"] = DateTime.parse(event["TimeStart"]).utc.to_i * 1000
      event["TimeEnd"] = DateTime.parse(event["TimeEnd"]).utc.to_i * 1000
      if event["TimeStart"] >= params[:start].to_i and event["TimeEnd"] < params[:end].to_i
        if taked_id.include? event["CourseNo"]
          events.push(event)
        end
      end
    end
    render :json=>events
    # render file: "calendar/test.json", layout: false, content_type: 'application/json' 
  end

end
