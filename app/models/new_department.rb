class NewDepartment < ActiveRecord::Base
	has_many :courses
end
