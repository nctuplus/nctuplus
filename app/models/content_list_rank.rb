class ContentListRank < ActiveRecord::Base
	belongs_to :raider_content_list
	belongs_to :user
end