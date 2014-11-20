class UserCoursemapship < ActiveRecord::Base
	belongs_to :user
	belongs_to :course_map
end
