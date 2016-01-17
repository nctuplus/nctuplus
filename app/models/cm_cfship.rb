class CmCfship < ActiveRecord::Base
	
	belongs_to :course_field
	belongs_to :course_map
		
end
