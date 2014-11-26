class NewCourseDetail < ActiveRecord::Base
	#validates_uniqueness_of :unique_id
	belongs_to :new_course_teachership, :foreign_key=>"course_teachership_id"
	has_one :new_course, :through=>:new_course_teachership
end
