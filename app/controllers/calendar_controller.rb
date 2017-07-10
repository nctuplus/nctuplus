class CalendarController < ApplicationController
    def index
    end

    def get_event
        render file: "calendar/test.json", layout: false, content_type: 'application/json' 
    end

end
