class SubDiscuss < ActiveRecord::Base
	belongs_to :discuss
	belongs_to :user
end
