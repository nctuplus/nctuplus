class Event < ActiveRecord::Base
	
	belongs_to :user
	has_attached_file :cover,
		:url=>"/file_upload/event_covers/:id_partition/:filename",
		:default_url => "/images/:style/missing.png",
		:path => ":rails_root/public/file_upload/event_covers/:id_partition/:filename"
  validates_attachment :cover, 
		:content_type => { :content_type => /\Aimage\/.*\Z/ },
		:size => { :less_than => 2.megabytes }
		
	def to_json_obj
		{
			:id=>self.id,
			:title=>self.title,
			:start=>self.begin_time.strftime("%Y-%m-%dT%H:%M:00"),
			:end=>self.end_time.strftime("%Y-%m-%dT%H:%M:00"),
			:className=>self.event_type
		}
	end
end
