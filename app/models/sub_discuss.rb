class SubDiscuss < ActiveRecord::Base
	belongs_to :discuss
	belongs_to :user
	#delegate :name,:uid, :to=>:user, :prefix=>true
	validates_presence_of :content, :user_id, :discuss_id
	def owner_name
		return self.is_anonymous ? "匿名" : self.try(:user).try(:name)
	end
	def recent_obj
		return {
			:type=>"sub",
			:id=>self.discuss.id,
			:title=>self.discuss.title,
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
			:hasSocial=>self.user.hasSocialAuth?,
			:is_anonymous=>self.is_anonymous,
			:editable=>self.user_id==current_user_id,
			:user_name=>self.owner_name,
			:content=>self.content,
			:time=>self.updated_at.strftime("%Y/%m/%d %H:%M"),
			:imgsrc=> src,
      :webpage=> self.user.social_webpage_url,
		}
	end
end
