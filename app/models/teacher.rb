class Teacher < ActiveRecord::Base
  belongs_to :department
 # belongs_to :course, :through => course_teacherships
  has_many :courses, :through => :course_teacherships
end
