class CourseMapPublicSubComment < ActiveRecord::Base

	belongs_to :user
	belongs_to :course_map
	belongs_to :course_map_public_comment, :foreign_key=>"comment_id"

	def to_hash
		return {
			:id=> self.id,
			:user=>{:id=>self.user_id, :name=>self.user.name},
			:comments=> self.comments,
			:time=>self.updated_at.strftime("%F %R"),
		}
	end

end