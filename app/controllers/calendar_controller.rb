class CalendarController < ApplicationController
  
  before_filter :checkLogin, :only=>[:index, :get_event]

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
      event["TimeStart"] = DateTime.parse(event["TimeStart"]).to_i * 1000
      event["TimeEnd"] = DateTime.parse(event["TimeEnd"]).to_i * 1000
      if taked_id.include? event["CourseNo"]
        if event["MaterialType"] == "announcement"
          if event["TimeStart"] >= params[:start].to_i and event["TimeStart"] < params[:end].to_i
            events.push(event)
          end
        elsif event["MaterialType"] == "assignment"
          if event["TimeEnd"] >= params[:start].to_i and event["TimeEnd"] < params[:end].to_i
            events.push(event)
          end
        end
      end
    end
    render :json=>events
    # render file: "calendar/test.json", layout: false, content_type: 'application/json' 
  end

end
