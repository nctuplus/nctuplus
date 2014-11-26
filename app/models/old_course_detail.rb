class OldCourseDetail < ActiveRecord::Base
	belongs_to :old_course_teachership, :foreign_key=>"course_teachership_id"
	belongs_to :semester
	has_one :old_course, :through=>:old_course_teachership
	#has_one :department, :through=>:course

	
end
