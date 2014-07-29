class RaiderContentList < ActiveRecord::Base
	belongs_to :course_teacher_page_content
	belongs_to :user
	has_many :content_list_ranks, :dependent => :destroy
	
end
