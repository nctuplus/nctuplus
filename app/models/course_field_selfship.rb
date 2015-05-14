class CourseFieldSelfship < ActiveRecord::Base
	belongs_to :parent_cf, foreign_key: "parent_id", :class_name=>"CourseField"
	#belongs_to :course_field, foreign_key: "parent_id"
	#belongs_to :course_field, foreign_key: "child_id"
	belongs_to :child_cf, foreign_key: "child_id", :class_name=>"CourseField"
end
