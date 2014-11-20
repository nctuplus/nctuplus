class NewCourseDetail < ActiveRecord::Base
	validates_uniqueness_of :unique_id
end
