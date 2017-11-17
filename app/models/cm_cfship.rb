class CmCfship < ApplicationRecord

	
	after_destroy :destroy_cf
	
	belongs_to :course_field
	belongs_to :course_map
	
	def destroy_cf
	#	p "!!!!!!　#{self.course_field_id}"
		self.course_field.destroy
	end
end
