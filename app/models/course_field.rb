class CourseField < ActiveRecord::Base
	has_many :course_field_lists, :dependent => :destroy
	has_many :course_field_selfships, :dependent => :destroy, foreign_key: "parent_id"
	has_many :course_fields, :through=> :course_field_selfships
	has_many :courses, :through=> :course_field_lists
	has_many :course_groups, :through =>:course_field_lists
	belongs_to :course_field_group
	belongs_to :user
	#belongs_to :course_simulation
	

	
end
