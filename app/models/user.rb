class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
	       :omniauthable, :omniauth_providers => [:facebook, :E3]
	belongs_to :department
	has_one :auth_facebook
	has_one :auth_e3
	
	delegate :ch_name, :to=> :department, :prefix=>true
	delegate :degree, :to=> :department
	delegate :uid, :to=> :auth_facebook
	
	
	
	
	has_many :past_exams
	has_many :discusses
	has_many :sub_discusses
	has_many :discuss_likes
	has_many :course_content_lists
	has_many :content_list_ranks
	has_many :comments
	has_many :course_teacher_ratings
	
	#has_many :course_simulations, :dependent=> :destroy
	
	has_many :user_coursemapships, :dependent=> :destroy
	has_many :course_maps, :through=> :user_coursemapships
	
	has_many :agreed_scores, :dependent=> :destroy
	
	has_many :normal_scores, :dependent=> :destroy
	has_many :course_details, :through=> :normal_scores
	has_many :semesters, :through=> :course_details
	

	def student_id
	  self.try(:auth_e3).try(:student_id)
	end


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
	
	
	
	
=begin
	def all_courses
		self.course_simulations.import_success.includes(:course_detail, :course_teachership, :course, :course_field)
	end
	def courses_taked
		self.all_courses.normal
	end

	
	def courses_agreed
		self.course_simulations.includes(:course_detail, :course, :course_field).import_success.agreed
	end
=end
	
	def courses_taked
		self.normal_scores.includes(:course_detail, :semester, :course_teachership, :course, :course_field)
	end
	
	def courses_agreed
		self.agreed_scores.includes(:course, :course_field)
	end
	

	def total_credit
		def pass_courses
			self.normal_scores.includes(:course, :course_detail).where("score = '通過' OR score >= ?",self.pass_score)
		end
		return (self.pass_courses+self.agreed_scores).map{|cs|cs.credit.to_i}.reduce(:+)||0
	end
	
	def courses_json
		taked=self.courses_taked.order("course_field_id DESC").map{|cs|
			cs.to_stat_json
		}
		agreed=self.courses_agreed.order("course_field_id DESC").map{|cs|
			cs.to_stat_json
		}
		return (taked+agreed).sort_by{|x|x[:cf_id]}.reverse
	end
	def courses_stat_table_json
		taked=self.courses_taked.order("course_field_id DESC").map{|cs|
			cs.to_stat_table_json
		}
		agreed=self.courses_agreed.order("course_field_id DESC").map{|cs|
			cs.to_stat_json
		}
		return (taked+agreed).sort_by{|x|x[:cf_id]}.reverse
	end

  def self.create_from_auth(hash)
    user = self.new
    user.name = hash[:name]
    user.email = hash[:email]
    user.password = hash[:password] 
    user.save!
    return user
  end
  
end