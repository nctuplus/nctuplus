class Event < ActiveRecord::Base
	has_one :event_image, :dependent=> :destroy
	belongs_to :user
end
