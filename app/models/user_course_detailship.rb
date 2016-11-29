class UserCourseDetailship < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_detail    
end
