class Course < ActiveRecord::Base
	belongs_to :grade
	has_many :file_info
end
