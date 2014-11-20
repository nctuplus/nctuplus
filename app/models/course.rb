class Course < ActiveRecord::Base
	belongs_to :grade
	belongs_to :department#, :class_name=>"NewDepartment"
	belongs_to :user
	#belongs_to :course_field_list
#	has_many :teachers, :through => :course_details
	#has_many :semester_courseships, :dependent => :destroy
	has_many :course_field_lists
	has_many :course_fields, :through=>:course_field_lists
	has_many :course_teacherships, :dependent => :destroy
	has_many :course_details, :through=> :course_teacherships#, :source=>course_details
	has_many :teachers, :through => :course_teacherships
	
	has_many :semesters, :through => :course_details

	
	has_many :reviews
	
	def _credit
		self.course_details.take.credit.to_i
	end
	
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
	
	
	
	#UNRANSACKABLE_ATTRIBUTES = ["ch_name"]

  #def self.ransackable_attributes auth_object = nil
  #  (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  #end
	
end
