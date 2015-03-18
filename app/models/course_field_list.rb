class CourseFieldList < ActiveRecord::Base
	belongs_to :course
	belongs_to :user
	belongs_to :course_group
	belongs_to :course_field
	
	
	#has_one :course
end
