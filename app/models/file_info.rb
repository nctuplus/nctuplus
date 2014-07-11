class FileInfo < ActiveRecord::Base
  #attr_accessible :upload
  
  belongs_to :course
  
  has_attached_file :upload,  
    :storage => :dropbox,
    :dropbox_credentials => Rails.root.join("config/dropbox.yml"),
	:path => ":courseid/:userid/:filename"
  do_not_validate_attachment_file_type :upload
  include Rails.application.routes.url_helpers
 
  def to_jq_upload(user)
    if user
	  _uid=user.id
	else 
	  _uid=0
	end
	
    {
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:original),
      #"delete_url" => file_infos_path(self), will occur like /file_infos.5 and will show no route matches
      "delete_type" => "DELETE",
	  "id" => read_attribute(:id),
	  "teacher_name" => read_attribute(:teacher_id)==0 ? "All": Teacher.find(read_attribute(:teacher_id)).name,
	  "teacher_id" => read_attribute(:teacher_id),
	  "semester_name" => Semester.find(read_attribute(:semester_id)).name,
	  "semester_id" => read_attribute(:semester_id),
	  "course_name"=> Course.find(read_attribute(:course_id)).ch_name,
	  "description" =>read_attribute(:description),
	  "owner_name" =>User.find(read_attribute(:owner_id)).name,
	  "owner_id" =>read_attribute(:owner_id),
	  "create_time"=>read_attribute(:upload_updated_at).strftime("%F"),
	  "editable"=> _uid==read_attribute(:owner_id)
    }
  end
  
  def self.support_types
    "(gif|jpe?g|png|c|cpp|pdf|doc?x|ppt?x)"
  end
  def self.max_upload_size
    "10000000"
  end


  

end
