class CourseTeachership < ActiveRecord::Base
  has_many :course_details, :dependent=> :destroy
  belongs_to :course
  belongs_to :teacher
	
end
