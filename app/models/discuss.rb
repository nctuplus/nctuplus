class Discuss < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :user
	has_one :course, :through=>:course_teachership
	has_many :course_details, :through=>:course_teachership
	has_many :departments, :through=>:course_details
	has_many :colleges, :through=>:departments
	#has_many :discuss_verifies, :dependent => :destroy
	has_many :sub_discusses, :dependent => :destroy
	delegate :uid, :to=>:user, :prefix=>true
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
	def recent_obj
		return {
			:type=>"main",
			:id=>self.id,
			:title=>self.title,
			:ct_name=>self.course_ch_name,#/#{self.course_teachership.teacher_name}",
			:user_name=>self.owner_name,
			:time=>self.created_at
		}
	end
	def show_obj(current_user_id)
		if self.is_anonymous
			src=ActionController::Base.helpers.asset_path("anonymous.jpg")
		else
			src=self.user.avatar_url
		end
		return {
			:id=>self.id,
			:is_anonymous=>self.is_anonymous,
			:editable=>self.user_id==current_user_id,
			:hasSocial=>self.user.hasSocialAuth?,
			:ct_name=>"#{self.course_ch_name}/#{self.course_teachership.teacher_name}",
			:cd_id=>self.course_teachership.try(:course_details).try(:last).try(:id),
			:user_name=>self.owner_name,
			:title=>self.title,
			:content=>self.content,
			:time=>self.updated_at.strftime("%Y/%m/%d %H:%M"),
			:sub_discusses=>self.sub_discusses.includes(:user).map{|sub_d|sub_d.show_obj(current_user_id)},
			:imgsrc=> src,
      :webpage=> self.user.social_webpage_url,
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
