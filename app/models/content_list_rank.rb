class ContentListRank < ActiveRecord::Base
	belongs_to :course_content_list
	belongs_to :user
end