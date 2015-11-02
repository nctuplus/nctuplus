class SubDiscuss < ActiveRecord::Base
	belongs_to :discuss
	belongs_to :user
	has_many :discuss_likes, :dependent => :destroy
	delegate :name,:uid, :to=>:user, :prefix=>true
	validates_presence_of :content, :user_id, :discuss_id
	def to_json_obj(current_user_id)
		if !self.user.hasFb?
			src=ActionController::Base.helpers.asset_path("anonymous.jpg")
		else
			src="http://graph.facebook.com/#{self.user.uid}/picture"
		end
		return {
			:id=>self.id,
			:uid=>self.user.try(:uid),
			:editable=>self.user_id==current_user_id,
			:likes=>self.discuss_likes.count,
			:user_name=>self.user_name,
			:content=>self.content,
			:time=>self.updated_at.strftime("%Y/%m/%d %H:%M"),
			:imgsrc=> src,
		}
	end
end
