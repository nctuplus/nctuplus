class DiscussLike < ActiveRecord::Base
	belongs_to :discuss
	belongs_to :sub_discuss
	validates_presence_of :user_id
end
