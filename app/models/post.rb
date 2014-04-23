class Post < ActiveRecord::Base
  has_many :course_postships, :dependent => :destroy
  has_many :courses, :through => :course_postships
end
