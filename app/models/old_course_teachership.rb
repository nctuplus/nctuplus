class OldCourseTeachership < ActiveRecord::Base
	belongs_to :old_course, :foreign_key=>"course_id"
	has_many :old_course_details, :dependent=> :destroy, :foreign_key=>"course_teachership_id"
end
