class DiscussLike < ActiveRecord::Base
	belongs_to :discuss
	belongs_to :sub_discuss
end
