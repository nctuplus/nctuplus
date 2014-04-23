class Course < ActiveRecord::Base
	belongs_to :grade
	has_many :file_info
	has_many :course_postships, :dependent => :destroy
	has_many :posts, :through => :course_postships
end
