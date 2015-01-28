class Event < ActiveRecord::Base
	has_one :event_image, :dependent=> :destroy
end
