class UserScore < ActiveRecord::Base
	belongs_to :user
	belongs_to :course_detail,inverse_of: :user_scores#foreign_type:"is_agreed", foreign_key: "target_id"
	#belongs_to :course,foreign_type:"is_agreed", foreign_key: "target_id"
	#has_one :course,->{where is_agreed: true}, foreign_key: "target_id"
	#has_one :course
end
