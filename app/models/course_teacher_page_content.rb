class CourseTeacherPageContent < ActiveRecord::Base
	belongs_to :course_teachership
	has_many :raider_content_lists
end
