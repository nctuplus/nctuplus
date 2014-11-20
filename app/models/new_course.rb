class NewCourse < ActiveRecord::Base
	
	validates_uniqueness_of :real_id
end
