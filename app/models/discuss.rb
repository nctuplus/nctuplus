class Discuss < ActiveRecord::Base
	belongs_to :course_teachership#, counter_cache: true
	belongs_to :user
	has_many :discuss_likes, :dependent => :destroy
	has_many :sub_discusses, :dependent => :destroy
	delegate :name, :uid, :to=>:user, :prefix=>true
	validates_presence_of :title, :content, :user_id, :course_teachership_id

	
end
