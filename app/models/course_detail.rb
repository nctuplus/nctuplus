class CourseDetail < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :semester
	#belongs_to :course
	
	has_one :course, :through=>:course_teachership
	has_many :teachers, :through=>:course_teachership
	#belongs_to :course
	#belongs_to :teacher
	has_one :department, :through=>:course
	#has_one :course_teachership
  #belongs_to :course
  #belongs_to :teacher
	
	has_many :user_scores,->{where is_agreed:false}, foreign_key: "parent_id"
	
	#def teachers
	#	self.course_teachership._teachers
	#end
	
	def teacher_name
		self.course_teachership.teacher_name
	end
	
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
	
	ransacker :by_teacher_name, :formatter => proc {|v| 
		zz=Teacher.where("name like ?","%#{v}%")
		if zz.empty?
			[0]
		else
			zz.map{|t|t.course_teacherships.map{|ct|ct.id}}.flatten
		end
	},:splat_param => true do |parent|
			parent.table[:course_teachership_id]
  end
	def testGG(arr)
		if arr.nil?
			return [0]
		else
			return arr.map{|t|t.course_teacherships.map{|ct|ct.id}}.flatten
		end
	end
	# ransacker :by_dept_id, :formatter => proc {|v| 
		# CourseTeachership.select(:id).where(
			# :course_id=>Course.select(:id).where(:department_id => v)
		# ).pluck(:id)
	# }, :splat_param => true do |parent|
    # parent.table[:course_teachership_id]
  # end
	
end
