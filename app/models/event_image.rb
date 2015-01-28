class EventImage < ActiveRecord::Base
	has_attached_file :img,
		:default_url => "/images/:style/missing.png",
		:default_style => :medium,
		#:use_timestamp => false,
		:url => '/event_images/:id/:filename'#,
		#:path => '/event/show_image/:id'
	
  validates_attachment_content_type :img, :content_type => /\Aimage\/.*\Z/
	validates_with AttachmentSizeValidator, :attributes => :img, :less_than => 4.megabytes
end
