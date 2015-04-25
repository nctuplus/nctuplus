class CourseMap < ActiveRecord::Base
	#has_many :course_field_groups, :dependent => :destroy
	has_many :cm_cfships, :dependent => :destroy
	has_many :course_fields, :through => :cm_cfships, :dependent => :destroy
	has_many :course_groups, :dependent => :destroy
	has_many :user_coursemapships, :dependent => :destroy
	has_many :course_map_public_comments, :dependent => :destroy
	belongs_to :semester
	belongs_to :department
	belongs_to :user
	
	def to_tree_json
		self.course_fields.includes(:course_field_lists, :courses, :child_cfs, :cf_credits).map{|cf|
			cf.field_type < 3 ? cf.get_bottom_node : cf.get_middle_node
		}	
	end
	
	def comments
		return self.course_map_public_comments.order('updated_at DESC').map{|comment| comment.to_hash}
	end
end
