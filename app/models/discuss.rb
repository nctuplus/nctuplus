class Discuss < ActiveRecord::Base
	belongs_to :course_teachership#, counter_cache: true
	belongs_to :user
	has_many :discuss_likes, :dependent => :destroy
	has_many :sub_discusses, :dependent => :destroy
	validates_presence_of :title, :content
	
	def check_owner()
	
	end
	#validates_presence_of :content
end
