class Attendance < ApplicationRecord
	belongs_to :user
	belongs_to :event, :counter_cache => true
end
