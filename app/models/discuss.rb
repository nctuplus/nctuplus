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
	def to_json_obj
		if self.is_anonymous
			src=ActionController::Base.helpers.asset_path("anonymous.jpg")
		else
			src="http://graph.facebook.com/#{self.user.uid}/picture"
		end
		return {
			:id=>self.id,
			:uid=>self.user.uid,
			:title=>self.title,
			:content=>self.content,
			:time=>self.created_at.strftime("%Y/%m/%d %H:%M"),
			:sub_discusses=>self.sub_discusses,
			:imgsrc=> src
		}
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
