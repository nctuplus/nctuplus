class CourseTeachership < ActiveRecord::Base
  has_many :course_details, :dependent=> :destroy
	has_many :course_teacher_ratings, :dependent=> :destroy
	has_many :discusses
  has_one :course_content_head
  has_many :course_content_lists
	
  belongs_to :course
  belongs_to :teacher
	
end
