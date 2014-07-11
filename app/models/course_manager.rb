class CourseManager < ActiveRecord::Base
  #has_many :courses, :through=>course_manager
  belongs_to :course
  belongs_to :user
end
