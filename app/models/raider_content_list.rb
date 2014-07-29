class RaiderContentList < ActiveRecord::Base
	belongs_to :course_teacher_page_content
	belongs_to :user
	
end
