class SubDiscuss < ActiveRecord::Base
	belongs_to :discuss
	belongs_to :user
	has_many :discuss_likes, :dependent => :destroy
	delegate :name,:uid, :to=>:user, :prefix=>true
	validates_presence_of :content, :user_id, :discuss_id
end
