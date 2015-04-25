class CourseMapPublicComment < ActiveRecord::Base

belongs_to :user
belongs_to :course_map
has_many :course_map_public_sub_comments

	def to_hash
		return {
			:id=> self.id,
			:user=>{:id=>self.user_id, :name=>self.user.name},
			:comments=> self.comments,
			:checked=> self.checked,
			:time=>self.updated_at.strftime("%F %R"),
			:child_comments=> self.course_map_public_sub_comments.order('updated_at ASC').map{|sub_comment| sub_comment.to_hash}		
		}
	end

end