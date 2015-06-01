class NormalScore < ActiveRecord::Base
	belongs_to :course_detail
	delegate :semester_id,:temp_cos_id,:brief,:course_teachership_id, :to=>:course_detail
	
	has_one :semester, :through=>:course_detail
	delegate :name, :to=>:semester, :prefix=>true
	
	has_one :department, :through=>:course_detail
	delegate :ch_name, :to=>:department, :prefix=>true
	
	has_one :course_teachership, :through=>:course_detail
	
	has_one :course, :through=>:course_detail
	delegate :credit, :ch_name, :to=>:course
	
	belongs_to :course_field
	delegate :name, :to=>:course_field, :prefix=>true
	
	def self.create_form_import(user_id,cd_id,data)
		self.create(
			:user_id=>user_id,
			:course_detail_id=>cd_id,
			:score=>data['score']=="" ? "修習中" : data['score'],
			:cos_type=>data['cos_type']
		)
	end
	
	def self.search_by_sem_id(sem_id)
		ransack(:course_detail_semester_id_eq=>sem_id).result
	end
	
	def to_basic_json
		{
			:name=>self.ch_name,	
			:cos_id=>self.course.id,
			:cd_id=>self.course_detail_id,
			:sem_name=>self.semester_name,
			:t_name=>self.course_detail.teacher_name,
			:temp_cos_id=>self.temp_cos_id,
			#:file_count=>self.course_teachership.past_exams.count.to_s,
			#:discuss_count=>self.course_teachership.discusses.count.to_s,
			:brief=>self.brief,
			:score=>self.score,
			:credit=>self.credit,
			:cos_type=>self.cos_type.blank? ? self.course_detail.cos_type : self.cos_type
		}
	end
	def to_stat_json
		self.to_basic_json.merge({			
			:id=>self.id,
			:cf_id=>self.course_field_id,
			:cf_name=>self.course_field ? self.course_field_name : ""
		})
	end
	
	def to_stat_table_json
		self.to_stat_json.merge({
			#:degree=>self.department.try(:degree)||0,
			:pass_score=>self.department.pass_score,
			:memo=>""
		})
	end
	
end
