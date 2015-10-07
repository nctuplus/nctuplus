class PastExam < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :course_teachership
	belongs_to :semester
	has_one :course, :through=>:course_teachership
	
	delegate :name, :to=>:user, :prefix=>true
	delegate :name, :to=>:semester, :prefix=>true
	
  #validates_presence_of :semester_id, :course_teachership_id

	has_attached_file :upload,  

	:path => ":rails_root/file_upload/:ct_id/:user_id/:filename",
  :url => "/past_exams/:id"

	do_not_validate_attachment_file_type :upload
  include Rails.application.routes.url_helpers
	

	def download_url
		upload.path(:original)
	end
	
	def to_jq_upload(user)
    {
      "name" => self.upload_file_name,
      "size" => self.upload_file_size,
      "url" => upload.url(:original),
			"download_times" => self.download_times.to_s,
			"id" => self.id,
			"semester_name" => self.semester_name,
			"semester_id" => self.semester_id,
			"description" =>self.description,
			"owner_name" =>self.user_name,
			"owner_id" =>self.user_id,
			"create_time"=>self.upload_updated_at.strftime("%F"),
			"editable"=> user.try(:id)==self.user_id 
    }
  end
	

=begin	
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
			"download_times" => read_attribute(:download_times).to_s,
      "delete_type" => "DELETE",
			"id" => read_attribute(:id),
			"semester_name" => Semester.find(read_attribute(:semester_id)).name,
			"semester_id" => read_attribute(:semester_id),
			"description" =>read_attribute(:description),
			"owner_name" =>User.find(read_attribute(:user_id)).name,
			"owner_id" =>read_attribute(:user_id),
			"create_time"=>read_attribute(:upload_updated_at).strftime("%F"),
			"editable"=> _uid==read_attribute(:user_id)
    }
  end
=end
  
  def self.support_types
    "(jpe?g|png|pdf|docx?|pptx?|zip|rar)"
  end
  def self.max_upload_size
    "10000000"
  end

	def self.search_by_text(text)
		search({
			:course_ch_name_or_description_cont=>text,
			:m=>"or",
			:by_teacher_name_in=>text
		})
	end
	private
	
  ransacker :by_teacher_name, :formatter => proc {|v| 
		teachers=Teacher.includes(:course_teacherships).where("name like ?","%#{v}%")
		ct_ids=teachers.map{|t|t.course_teacherships.map{|ct|ct.id}}.flatten
		ct_ids.empty? ? [0] :ct_ids
	},:splat_param => false do |parent|
			parent.table[:course_teachership_id]
  end
	
  

end
