class CourseTeachership < ActiveRecord::Base
  has_many :course_details, :dependent=> :destroy
	has_many :course_teacher_ratings, :dependent=> :destroy
	has_many :discusses
<<<<<<< HEAD
  has_one :course_content_head
  has_many :course_content_lists
=======
	has_many :file_infos
  has_one :course_teacher_page_content
>>>>>>> 21816fae2072db3e3091391f91759068ecd2dfff
	
  belongs_to :course
  belongs_to :teacher
	
end
