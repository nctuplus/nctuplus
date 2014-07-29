class User < ActiveRecord::Base
	belongs_to :department
	belongs_to :grade
  has_many :file_infos
  has_many :posts
  has_many :raider_content_lists
  has_many :content_list_ranks
	has_many :course_simulations#, :foreign_key=>:owner_id
  has_many :courses, :through=> :course_manager
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
	  
	  #if user.activated.nil?
			#user.grade_id = 1
	    #user.email = "not register yet"
	    #user.activated = 0
	  #end
			#user.grade_id=session[:grade_id].to_i
			#if session[:dept_id]
			#user.department_id=session[:dept_id].to_i
			
			#user.activated = user.department_id==0 ? 0 : 1 
			user.activated=0
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
			#session[:grade_id]=""
			#session[:dept_id]=""
    end
  end
end