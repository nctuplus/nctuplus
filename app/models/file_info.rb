class FileInfo < ActiveRecord::Base
  def self.support_types
    "(gif|jpe?g|png|c|cpp|pdf|doc|docx)"
  end
  def self.max_upload_size
    "10000000"
  end
  
  #has_attached_file :content,
  #:url => "./data_upload/:basename.:extension",
  #:path => "./data_upload/:courseid/:basename.:extension"
  
  #validates_attachment_content_type :content,
  #:content_type => ['application/pdf', 'application/msword', 'text/plain']

  belongs_to :course
  #def courseid
	#self.course_id
  #end
end
