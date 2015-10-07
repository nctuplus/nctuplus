class Discuss < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :user
	has_one :course, :through=>:course_teachership
	has_many :discuss_verifies, :dependent => :destroy
	has_many :discuss_likes, :dependent => :destroy
	has_many :sub_discusses, :dependent => :destroy
	delegate :name, :uid, :to=>:user, :prefix=>true
	validates_presence_of :title, :content, :user_id, :course_teachership_id

	def self.search_by_text(text)
		search({
			:course_ch_name_or_title_cont=>text,
			:m=>"or",
			:by_teacher_name_in=>text
		})
	end
	private
	
  ransacker :by_teacher_name, :formatter => proc {|v| 
		teachers=Teacher.includes(:course_teacherships).where("name like ?","%#{v}%")
		ct_ids=teachers.map{|t|t.course_teacherships.map{|ct|ct.id}}.flatten
		ct_ids.empty? ? [0] :ct_ids
	},:splat_param => false do |parent|
			parent.table[:course_teachership_id]
  end
	
end
