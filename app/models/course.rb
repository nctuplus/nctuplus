class Course < ActiveRecord::Base
	belongs_to :grade
	belongs_to :department
	belongs_to :user
	
#	has_many :teachers, :through => :course_details
	has_many :semester_courseships, :dependent => :destroy
	has_many :semesters, :through => :semester_courseships
	
	has_many :course_teacherships, :dependent => :destroy
	has_many :teachers, :through => :course_teacherships
	
	#has_many :course_details, :through=>course_teacherships#, :dependent => :destroy

	
	has_many :reviews
	
	def to_result(semester_name)
	
    {
			"id" => read_attribute(:id),
			"semester_name" => semester_name,
      "ch_name" => read_attribute(:ch_name),
      "eng_name" => read_attribute(:eng_name),
      "real_id" => read_attribute(:real_id),
			"department_name" => Department.find(read_attribute(:department_id)).ch_name#,
	  #"teacher_name" => read_attribute(:teacher_id)==0 ? "All": Teacher.find(read_attribute(:teacher_id)).name,
	  #"teacher_id" => read_attribute(:teacher_id),

	 
    }
  end
end
