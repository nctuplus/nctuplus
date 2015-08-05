class DiscussVerify < ActiveRecord::Base
	validates_uniqueness_of :discuss_id, :scope => :user_id
	belongs_to :discuss
	belongs_to :user
	delegate :name, :to=>:user, :prefix=>true
	
end
