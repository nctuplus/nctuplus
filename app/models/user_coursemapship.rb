class UserCoursemapship < ApplicationRecord
	belongs_to :user
	belongs_to :course_map
end
