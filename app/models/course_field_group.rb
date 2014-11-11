class CourseFieldGroup < ActiveRecord::Base
	has_many :course_fields, :dependent => :destroy
	belongs_to :user
end
