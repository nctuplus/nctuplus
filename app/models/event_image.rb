class EventImage < ActiveRecord::Base
	has_attached_file :img,
		:default_style => :medium,
		:default_url   => "/images/:style/missing.png",
		:url           => '/event_images/:id/:filename'
	
  validates_attachment_content_type :img, :content_type => /\Aimage\/.*\Z/
	validates_with AttachmentSizeValidator, :attributes => :img, :less_than => 4.megabytes
end
