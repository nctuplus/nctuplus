class CourseMap < ActiveRecord::Base
	#has_many :course_field_groups, :dependent => :destroy	
	has_many :course_fields, :through => :cm_cfships 
	#, :dependent => :destroy # dependent does not work
	has_many :cm_cfships, :dependent => :destroy
	has_many :course_groups, :dependent => :destroy
	has_many :user_coursemapships, :dependent => :destroy
	
	belongs_to :department
	delegate :ch_name, :to=>:department, :prefix=>true
	belongs_to :user
	
	def to_public_json
		{
			:id => self.id,
			#:name => course_map.department.ch_name+"入學年度:"+course_map.semester.year.to_s,
			:total_credit=>self.total_credit,
			:desc => self.desc,
			:cfs=>self.to_tree_json
		}
	end
	
	
	def to_tree_json
		self.course_fields.includes(:course_field_lists, :courses, :child_cfs, :cf_credits).map{|cf|
			cf.field_type < 3 ? cf.get_bottom_node : cf.get_middle_node
		}	
	end
	
### new react version
	def get_info # course map info
		return {
			:id=> self.id,
			:name=> self.name,
			:dep_id=> self.try(:department).try(:id),
			:dep_name=> self.try(:department).try(:ch_name),
			:year=> self.year,
			:credit=> self.total_credit,
			:desc=> self.desc
		}
	end

	def get_course_tree
		self.course_fields.includes(:course_field_lists, :courses, :child_cfs, :cf_credits)
		.map{ |cf| cf.get_tree_for_cm }
	end
	
	def get_course_group_tree
		self.course_groups.includes(:course_group_lists, :courses)
		.map{ |cg| cg.get_info_for_cm(false) }
	end
###
end
