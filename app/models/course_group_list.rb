class CourseGroupList < ActiveRecord::Base
	belongs_to :user
	belongs_to :course
	belongs_to :course_group
	#has_one :course
end
