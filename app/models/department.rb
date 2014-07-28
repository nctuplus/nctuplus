class Department < ActiveRecord::Base
  belongs_to :college
  has_many :courses
  has_many :teachers
	has_many :users
end
