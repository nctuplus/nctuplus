class Course < ActiveRecord::Base
	belongs_to :grade
	belongs_to :department#, :class_name=>"NewDepartment"
	belongs_to :user

	has_many :course_field_lists
	validates_associated :course_field_lists
	has_many :course_fields, :through=>:course_field_lists
	has_many :course_teacherships, :dependent => :destroy
	validates_associated :course_teacherships
	has_many :course_details, :through=> :course_teacherships#, :source=>course_details
	
	#has_many :teachers, :through => :course_teacherships
	
	has_many :semesters, :through => :course_details

		
	def to_result(semester_name)
    {
			"id" => read_attribute(:id),
			"semester_name" => semester_name,
      "ch_name" => read_attribute(:ch_name),
      "eng_name" => read_attribute(:eng_name),
      "real_id" => read_attribute(:real_id),
			"department_name" => Department.find(read_attribute(:department_id)).ch_name#,	 
    }
  end
	
	def to_json_for_stat
		{
			:ct_id=>self.course_teacherships.take.id,
			:name=>self.ch_name,
			:id=>self.id,
			:credit=>self.credit,
			:dept=>self.department ? self.department.ch_name : ""
		}
	end	
	
	
	#UNRANSACKABLE_ATTRIBUTES = ["ch_name"]

  #def self.ransackable_attributes auth_object = nil
  #  (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  #end
	
end
