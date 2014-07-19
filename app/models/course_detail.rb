class CourseDetail < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :semester
  #belongs_to :course, :through => :course_teachership
  #belongs_to :teacher, :through => :course_teachership
	def self.flit_semester(sem_id)
		self.select{|cd| cd.semester_id==sem_id}
	end
	
	def to_result(course)
	
    {
			"id" => course.id,
			"semester_name" => "!!",#,course.semester_name,
      "ch_name" => course.ch_name,
      #"eng_name" => course.eng_name,
      "real_id" => course.real_id,
			"department_name" => course.department.ch_name,
	    "teacher_name" => Teacher.find(read_attribute(:teacher_id)).name,
	  #"teacher_id" => read_attribute(:teacher_id),

	 
    }
  end
end
