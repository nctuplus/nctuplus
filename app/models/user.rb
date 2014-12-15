class User < ActiveRecord::Base
	
	belongs_to :department
	belongs_to :semester
	has_many :file_infos
	has_many :posts
	has_many :course_content_lists
	has_many :content_list_ranks
	has_many :comments
	has_many :course_simulations#, :foreign_key=>:owner_id
	#has_many :courses, :through=> :course_manager
	has_many :user_coursemapships
	has_many :course_maps, :through=> :user_coursemapships
	#validates_uniqueness_of [:uid, :student_id]
	validates :uid, :uniqueness => {:scope => [ :student_id]}
	def is_undergrad
		self.department && self.department.degree==3
	end
	def all_courses
		self.course_simulations.includes(:course_detail, :course_teachership, :course, :course_field).where("course_detail_id != 0")
	end
	
	def courses_this_sem
		self.all_courses.where("semester_id=?",latest_semester.id)
	end
	
	def courses_taked
		self.all_courses.where("semester_id != 0")
	end
	def courses_agreed
		self.course_simulations.includes(:course_detail, :course, :course_field).where("course_detail_id != 0 AND semester_id = 0")
	end
	
	def pass_courses
		self.course_simulations.includes(:course, :course_detail).where("(semester_id !=0) AND (score = '通過' OR score>= ?)",self.pass_score)
	end
	
	
	def pass_score
		return self.is_undergrad ? 60 : 70
	end
	def total_credit
		return self.pass_courses.map{|cs|cs.course.credit.to_i}.reduce(:+)||0
	end
	
	def courses_json
		return self.all_courses.order("course_field_id DESC").map{|cs|{
			:name=>cs.course.ch_name,
			:cs_id=>cs.id,
			:course_id=>cs.course.id,
			:ct_id=>cs.course_teachership.id,
			:cos_type=>cs.course_detail.cos_type,
			:sem_id=>cs.semester_id,
			:brief=>cs.course_detail.brief,
			:credit=>cs.course.credit,
			:cf_id=>cs.course_field_id ? cs.course_field_id : 0,
			:score=>cs.semester_id==0 ? cs.memo : cs.semester_id==Semester.last.id ? "修習中" : cs.score
		}}
	end
	
	
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
			
			
			#user.activated = user.department_id==0 ? 0 : 1 
			#user.activated=0
			#user.department_id=0
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
			#session[:grade_id]=""
			#session[:dept_id]=""
    end
  end
end