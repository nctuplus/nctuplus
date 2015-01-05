class CourseDetail < ActiveRecord::Base
	belongs_to :course_teachership
	delegate :teacher_name, :to=>:course_teachership
	has_many :file_infos, :through=>:course_teachership
	has_many :discusses, :through=>:course_teachership
	has_one :course, :through=>:course_teachership
	delegate :ch_name,:credit, :to=>:course, :prefix=>true
	has_many :teachers, :through=>:course_teachership	
	
	belongs_to :semester
	delegate :name, :to=>:semester, :prefix=>true
	belongs_to :department
	delegate :ch_name, :to=>:department, :prefix=>true

	
	def incViewTimes!
		update_attributes(:view_times=>self.view_times+1)
	end
	
	def self.flit_semester(sem_id)
		self.select{|cd| cd.semester_id==sem_id}
	end
	
	def to_search_result
		{
			:id=>self.id,
			:grade=>self.grade=="*" ? "all" : self.grade ,
			:cos_type=>self.cos_type,
			:time=>self.time,
			:course_name=>self.course_ch_name,
			:credit=>self.course_credit,
			:dept_name=>self.department_ch_name,
			:teacher_name=>self.teacher_name,
			:ct_id=>self.course_teachership_id
		}
	end
	
	def to_course_table_result
		{
			:course_id=>self.id,
			:time=>self.time,
			:class=>cos_type_class(self.cos_type),
			:room=>self.room,
			:name=>self.course_ch_name		
		}
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
	
private
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

  def cos_type_class(cos_type)
		prefix="course-"
		case cos_type
			when "共同必修"
				type="common-required"
			when "共同選修"
				type="common-elective"
			when "通識"
				type="general"
			when "必修"
				type="required"
			when "選修"
				type="elective"
			when "外語"
				type="foreign"
			else
				type="error"
		end
		return prefix+type
  end
	
end
