class User < ActiveRecord::Base
	
	belongs_to :department
	delegate :ch_name, :to=> :department, :prefix=>true
	delegate :degree, :to=> :department
	
	has_many :past_exams
	has_many :discusses
	has_many :sub_discusses
	has_many :discuss_likes
	has_many :course_content_lists
	has_many :content_list_ranks
	has_many :comments
	has_many :course_teacher_ratings
	
	has_many :course_simulations, :dependent=> :destroy
	has_many :user_coursemapships, :dependent=> :destroy
	has_many :course_maps, :through=> :user_coursemapships
	
	validates :uid, :uniqueness => {:scope => [ :student_id]}

	
	def merge_child_to_newuser(new_user)	#for 綁定功能，將所有user有的東西的user_id改到新的user id
		table_to_be_moved=User.reflect_on_all_associations(:has_many).map { |assoc| assoc.name}
		table_to_be_moved.each do |table_name|
			self.send(table_name).update_all(:user_id=>new_user.id)
		end
		self.destroy
	end

	
	def hasFb?
		return self.provider=="facebook"
	end
	
## role func
	def isAdmin?
		return self.role==0
	end
	
	def isOffice?
		return self.role==2
	end	
	
	def isNormal?
		return self.role==1
	end
##	

	def is_undergrad?
		return self.department && self.department.degree==3
	end
	
	def pass_score
		return self.is_undergrad? ? 60 : 70
	end
	
	def all_courses
		self.course_simulations.import_success.includes(:course_detail, :course_teachership, :course, :course_field)
	end

	def courses_taked
		self.all_courses.normal
	end
	
	def courses_agreed
		self.course_simulations.includes(:course_detail, :course, :course_field).import_success.agreed#where("course_detail_id != 0 AND semester_id = 0")
	end
	
	

	def total_credit
		def pass_courses
			self.course_simulations.includes(:course, :course_detail).where("(semester_id !=0) AND (score = '通過' OR score>= ?)",self.pass_score)
		end
		return self.pass_courses.map{|cs|cs.course.credit.to_i}.reduce(:+)||0
	end
	
	def courses_json
		return self.all_courses.order("course_field_id DESC").map{|cs|{
			:name=>cs.course.ch_name,
			:cs_id=>cs.id,
			:course_id=>cs.course.id,
			:ct_id=>cs.course_teachership.id,
			:cos_type=>cs.cos_type=="" ? cs.course_detail.cos_type : cs.cos_type,
			:sem_id=>cs.semester_id,
			:brief=>cs.course_detail.brief,
			:credit=>cs.course.credit,
			:cf_id=>cs.course_field_id ? cs.course_field_id : 0,
			:score=>cs.semester_id==0 ? cs.memo : cs.semester_id==Semester::LAST.id ? "修習中" : cs.score
		}}
	end
		
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end
   
  
  
end