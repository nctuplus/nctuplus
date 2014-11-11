class CourseFieldSelfship < ActiveRecord::Base
	belongs_to :course_field, foreign_key: "parent_id"
	belongs_to :course_field, foreign_key: "child_id"
end
