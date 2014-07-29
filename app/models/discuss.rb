class Discuss < ActiveRecord::Base
	belongs_to :course_teachership
	belongs_to :user
	has_many :sub_discusses, :dependent => :destroy
end
