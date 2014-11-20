class CourseMap < ActiveRecord::Base
	#has_many :course_field_groups, :dependent => :destroy
	has_many :cm_cfships, :dependent => :destroy
	has_many :course_fields, :through => :cm_cfships, :dependent => :destroy
	has_many :course_groups, :dependent => :destroy
	belongs_to :semester
	belongs_to :department
	belongs_to :user
end
