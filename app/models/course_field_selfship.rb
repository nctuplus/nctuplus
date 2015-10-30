class CourseFieldSelfship < ActiveRecord::Base
	
	before_destroy :destroy_child_cf
	
	belongs_to :parent_cf, foreign_key: "parent_id", :class_name=>"CourseField"
	belongs_to :child_cf, foreign_key: "child_id", :class_name=>"CourseField"

	def destroy_child_cf
	#	p "!!!!!!!!!! #{self.child_cf.id}"
		self.child_cf.destroy
	end
		
end
