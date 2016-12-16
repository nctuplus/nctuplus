class UserCourseDetailship < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_detail    

  validates :course_detail_id, presence: true
  validates :user_id, presence: true
end
