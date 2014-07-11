class Semester < ActiveRecord::Base
  has_many :semester_courseships, :dependent => :destroy
  has_many :courses, :through => :semester_courseships

end
