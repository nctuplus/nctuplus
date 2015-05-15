class CourseDetail < ActiveRecord::Base
	belongs_to :course_teachership
	delegate :teacher_name, :to=>:course_teachership
	has_many :past_exams, :through=>:course_teachership
	has_many :discusses, :through=>:course_teachership
	has_one :course, :through=>:course_teachership
	delegate :ch_name,:credit, :to=>:course, :prefix=>true
	has_many :teachers, :through=>:course_teachership	
	
	belongs_to :semester
	delegate :name, :to=>:semester, :prefix=>true
	belongs_to :department
	delegate :ch_name, :to=>:department, :prefix=>true, allow_nil: true

	has_many :course_simulations, :dependent=> :destroy
	

	def self.searchByText(text,sem_id)
		search({
			:course_ch_name_or_time_or_brief_cont=>text,
			:semester_id_eq=>sem_id,
			:m=>"or",
			:by_teacher_name_in=>text
		})
	end
	
	
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
			:ct_id=>self.course_teachership_id,
			:reg_num=>self.reg_num,
			:reg_limit=>self.students_limit=="9999" ? "不限" : self.students_limit,
			:brief=>self.brief
		}
	end
	
	def to_course_table_result
		{
			:cd_id=>self.id,
			:time=>self.time,
			:class=>cos_type_class(self.cos_type),
			:room=>self.room,
			:name=>self.course_ch_name		
		}
	end
	
	def self.save_from_e3(data,ct_id,sem_id)
		cd=CourseDetail.where(:temp_cos_id=>data["cos_id"], :semester_id=>sem_id).take
		if cd.nil?
			cd=CourseDetail.new 
			ret="Create"
		else
			ret="Update"
		end
		cd.course_teachership_id=ct_id
		cd.department_id=Department.get_by_degree_and_depid(data["degree"].to_i,data["dep_id"])
		cd.semester_id=sem_id
		cd.grade=data["grade"]
		costime=data['cos_time'].split(',')
		cd.time=""
		cd.room=""
		costime.each do |t|
			_time=t.partition('-')
			cd.time<<_time[0]
			cd.room<<_time[2]
		end
		cd.cos_type=data["cos_type"]
		cd.temp_cos_id=data["cos_id"]
		cd.memo=data["memo"]
		cd.students_limit=data["num_limit"]
		cd.reg_num=data["reg_num"]
		cd.brief=data["brief"]
		cd.save!
		return ret
	end

	
private
  ransacker :by_teacher_name, :formatter => proc {|v| 
		teachers=Teacher.includes(:course_teacherships).where("name like ?","%#{v}%")
		ct_ids=teachers.map{|t|t.course_teacherships.map{|ct|ct.id}}.flatten
		ct_ids.empty? ? [0] :ct_ids
	},:splat_param => false do |parent|
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
