class Teacher < ActiveRecord::Base
  belongs_to :department

	has_many :course_teacherships#, ->(teacher){ where "course_teacherships.teacher_id REGEXP ?","'[[.[.]|[.,.] ]#{teacher.id}[[.].]|[.,.]]" }

  has_many :courses, :through => :course_teacherships
	has_many :course_details, :through => :course_teacherships
	

	def course_teacherships
    CourseTeachership.where("teacher_id LIKE ?","%#{self.id}%").select{|ct|JSON.parse(ct.teacher_id).include?(self.id)}
		#CourseTeachership.where("teacher_id REGEXP ?","'[[.[.]|[.,.] ]#{self.id}[[.].]|[.,.]]")
	end
	

end
