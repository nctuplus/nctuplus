class TempCourseSimulation < ActiveRecord::Base
	belongs_to :old_course_detail, :foreign_key=>"course_detail_id"
	has_one :old_course, :through=>:old_course_detail
end