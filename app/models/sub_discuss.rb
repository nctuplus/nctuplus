class SubDiscuss < ActiveRecord::Base
	belongs_to :discuss
	belongs_to :user
	has_many :discuss_likes, :dependent => :destroy
end
