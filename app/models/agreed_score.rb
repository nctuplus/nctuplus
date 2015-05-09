class AgreedScore < ActiveRecord::Base
	belongs_to :course
	delegate :credit, :ch_name, :to=>:course
	belongs_to :course_field
	
	def self.create_form_import(user_id,course_id,data)
		self.create(
			:user_id=>user_id,
			:course_id=>course_id,
			:memo=>data[:memo],
			:cos_type=>data[:cos_type],
			:score=>"通過"
		)
	end
	
	def to_stat_json
		{
			:name=>self.ch_name,
			:cs_id=>self.id,
			:course_id=>self.course_id,
			:cos_type=>self.cos_type,
			:sem_name=>"抵免",			
			:credit=>self.credit,
			:cf_id=>self.course_field_id,
			:score=>self.score
		}
	end
	
	def to_basic_json
		{
			:name=>self.ch_name,
			:credit=>self.credit,
			:cos_type=>self.cos_type=="" ? self.course_detail.cos_type : self.cos_type,
			:cf_name=>self.course_field ? self.course_field.name : ""
		}
	end
	
end
