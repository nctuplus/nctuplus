class BookCtsship < ActiveRecord::Base
	belongs_to :book
	belongs_to :course_teachership
end