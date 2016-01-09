class Discuss < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :user
	has_one :course, :through=>:course_teachership
	has_many :course_details, :through=>:course_teachership
	has_many :departments, :through=>:course_details
	has_many :colleges, :through=>:departments
	#has_many :discuss_verifies, :dependent => :destroy
	#has_many :discuss_likes, :dependent => :destroy
	has_many :sub_discusses, :dependent => :destroy
	delegate :name, :uid, :to=>:user, :prefix=>true
	delegate :ch_name, :to=>:course, :prefix=>true
	validates_presence_of :title, :content, :user_id, :course_teachership_id

	def self.search_by_text(text)
		search({
			:course_ch_name_or_title_cont=>text,
			:m=>"or",
			:by_teacher_name_in=>text
		})
	end
	
	def owner_name
		return self.is_anonymous ? "匿名" : self.try(:user).try(:name)#user_name
	end
	
	def to_json_obj(current_user_id)
		if self.is_anonymous || !self.user.hasFb?
			src=ActionController::Base.helpers.asset_path("anonymous.jpg")
		else
			src="https://graph.facebook.com/#{self.user.uid}/picture"
		end
		return {
			:id=>self.id,
			:is_anonymous=>self.is_anonymous,
			:editable=>self.user_id==current_user_id,
			:uid=>self.user.try(:uid),
			#:likes=>self.discuss_likes.count,
			:ct_name=>"#{self.course_ch_name}/#{self.course_teachership.teacher_name}",
			:cd_id=>self.course_teachership.course_details.last.id,
			:user_name=>self.owner_name,#self.is_anonymous ? "匿名" : self.user_name,
			:title=>self.title,
			:content=>self.content,
			:time=>self.updated_at.strftime("%Y/%m/%d %H:%M"),
			:sub_discusses=>self.sub_discusses.includes(:user).order("updated_at DESC").map{|sub_d|sub_d.to_json_obj(current_user_id)},
			:imgsrc=> src,
			:isPreview=>false
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
