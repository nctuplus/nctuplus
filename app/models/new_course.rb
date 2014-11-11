class NewCourse < ActiveRecord::Base
	validates_uniqueness_of :unique_id
	validates_uniqueness_of :real_id
end
