class Background < ActiveRecord::Base
  validates_presence_of :image
  has_attached_file :image,
		:default_style => :medium,
		:url           => '/backgrounds/:id'
		
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
	validates_with AttachmentSizeValidator, :attributes => :image, :less_than => 1.megabytes
end
