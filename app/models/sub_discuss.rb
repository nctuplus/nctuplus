class SubDiscuss < ActiveRecord::Base
	belongs_to :discuss
	belongs_to :user
	has_many :discuss_likes, :dependent => :destroy
	#delegate :name,:uid, :to=>:user, :prefix=>true
	validates_presence_of :content, :user_id, :discuss_id
	def owner_name
		#return self.is_anonymous ? "匿名" : 
		self.try(:user).try(:name)
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
		if !self.user.hasFb?
			src=ActionController::Base.helpers.asset_path("anonymous.jpg")
		else
			src="https://graph.facebook.com/#{self.user.uid}/picture"
		end
		return {
			:id=>self.id,
			:uid=>self.user.try(:uid),
			:editable=>self.user_id==current_user_id,
			:likes=>self.discuss_likes.count,
			:user_name=>self.owner_name,
			:content=>self.content,
			:time=>self.updated_at.strftime("%Y/%m/%d %H:%M"),
			:imgsrc=> src,
		}
	end
end
