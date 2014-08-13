class CourseDetail < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :semester
	#belongs_to :course
	has_one :course, :through=>:course_teachership
	has_one :teacher, :through=>:course_teachership
	#has_one :course_teachership
  #belongs_to :course
  #belongs_to :teacher
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
	
	#private
	
	#ransacker :semester_id, formatter: proc { |v| v.reverse } do |parent|
	#	parent.table[:semester_id]
	#end
	
	# ransacker :by_course_name, :formatter => proc {|v| 
		# CourseTeachership.select(:id).where(
			# :course_id=>Course.select(:id).where("ch_name like ?","%#{v}%")
		# ).pluck(:id)||['0']
	# }, :splat_param => true do |parent|
    # parent.table[:course_teachership_id]
  # end
	
	# ransacker :by_dept_id, :formatter => proc {|v| 
		# CourseTeachership.select(:id).where(
			# :course_id=>Course.select(:id).where(:department_id => v)
		# ).pluck(:id)
	# }, :splat_param => true do |parent|
    # parent.table[:course_teachership_id]
  # end
	
end
