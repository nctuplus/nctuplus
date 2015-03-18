class CourseField < ActiveRecord::Base
	belongs_to :course_field_selfship
	belongs_to :user
	has_one :cm_cfship, :dependent => :destroy#, foreign_key: "child_id"
	has_one :course_map, :through=> :cm_cfship
	has_many :course_field_lists, :dependent => :destroy
	has_many :courses, :through=> :course_field_lists
	
	
	has_many :course_groups, :through =>:course_field_lists
	has_one :cm_cfship
	has_one :cf_field_need
	
	has_many :child_course_fieldships, :dependent => :destroy, foreign_key: "parent_id", :class_name=>"CourseFieldSelfship"
	has_many :child_cfs, :through=> :child_course_fieldships
	
	has_one :parent_course_fieldship, :dependent => :destroy, foreign_key: "child_id", :class_name=>"CourseFieldSelfship"
	has_one :parent_cf, :through =>:parent_course_fieldship

	has_many :cf_credits, :dependent => :destroy
	
	
	
	def field_need
		if self.cf_field_need
			return cf_field_need.field_need
		else
			return nil	
		end
	end

	def update_credit
		if self.field_type==1
			self.reload
			credit=0
			self.course_field_lists.each do |cfl|
				if cfl.record_type==1
					if cfl.course
						credit+=cfl.course.credit
					elsif cfl.course_groups
						credit+=cfl.course_group.lead_course.credit
					end
				end
			end
			
			self.cf_credits.first.update_attributes(:credit_need=>credit)
		end
		
	end
	
	
end
