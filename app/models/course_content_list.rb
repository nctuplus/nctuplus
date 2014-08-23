class CourseContentList < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :user
	has_many :content_list_ranks, :dependent => :destroy
	
end
