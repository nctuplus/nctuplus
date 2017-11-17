class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
	include ActionView::Helpers # for avatar
  devise :database_authenticatable, # :registerable, :recoverable,
         :rememberable, :trackable, # :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :nctu],
         :authentication_keys => [:id]
  belongs_to :department
  has_one :auth_nctu
  has_one :auth_facebook
  has_one :auth_e3
  has_one :auth_google
  
  delegate :ch_name, :to=> :department, :prefix=>true
  delegate :degree, :to=> :department
  #delegate :uid, :to=> :auth_facebook
  
  #these are important user data so can't add dependent=> :destroy!!
  has_many :book_trade_infos
  has_many :past_exams
  has_many :discusses
  has_many :sub_discusses
  has_many :course_content_lists
  has_many :content_list_ranks
  has_many :comments
  has_many :course_teacher_ratings
  
	has_many :events
	has_many :attendances
	has_many :event_follows
	has_many :attend_events, :through=> :attendances, :source=> :event
	has_many :follow_events, :through=> :attend_events, :source=> :event

  has_many :user_coursemapships, :dependent=> :destroy
  has_many :course_maps, :through=> :user_coursemapships
  has_many :admin_cms, :class_name=> "CourseMap"
  
  
  has_many :agreed_scores#, :dependent=> :destroy
  has_many :normal_scores#, :dependent=> :destroy

  #timetable collection
  has_many :user_collections#, :dependent=> :destroy
  
  has_many :bulletins

  #favorite couser
  has_many :user_favorite_courses, :dependent=> :destroy
  has_many :course_details, :through => :user_favorite_courses


  #validates :email, uniqueness: true
  validates :name, :length=> { :maximum=> 16, :message=>"姓名過長(max:16)" }, :on => :update #:uniqueness=>true,
 
# The :validatable parameter is removed. So we can have custom validation configs
  validates_format_of :email, :with  => Devise.email_regexp, :allow_blank => false

  # [Reserved]
#  validates_presence_of    :password, :on=>:create
#  validates_confirmation_of    :password, :on=>:create
#  validates_length_of    :password, :within => Devise.password_length, :allow_blank => true
  
  validates :department_id, :presence=> { message: "請填寫系所"}, :on => :update
  validates :year, :numericality=> { :greater_than=>0, :message=>"請填寫入學年度"}, :on => :update

  def avatar_url
    if self.hasFb?
      return "https://graph.facebook.com/#{self.auth_facebook.uid}/picture?type=large&redirect=true&width=140&height=140" 
    elsif self.hasGoogle?
      return self.auth_google.image_url
    else
      return ActionController::Base.helpers.asset_path("anonymous.jpg")
    end
  end
  
  def social_webpage_url
    if self.hasFb?
      return "https://www.facebook.com/#{self.auth_facebook.uid}"  
    elsif self.hasGoogle?
      return "https://www.plus.google.com/#{self.auth_google.uid}"  
    else
      return ""
      #raise "[ERROR] The user does not have soical auth."
    end
  end
  
# share course table
  def get_share_hasid(semester_id)
    return Hashid.user_share_encode([self.id, semester_id])
  end
  
  def canShare?
    return self.agree_share
  end

  def encrypt_id
    ENCRYTIONOBJ.encode(self.id)
  end
  

  def hasCollection?(user_id, semester_id)
    return self.user_collections.where(:target_id=>user_id, :semester_id=>semester_id).present?  
  end
  

  def student_id
    self.try(:auth_nctu).try(:student_id) || self.try(:auth_e3).try(:student_id)
  end
  
  def uid
    self.try(:auth_facebook).try(:uid)
  end


  def merge_child_to_newuser(new_user)  #for 綁定功能,將所有user有的東西的user_id改到新的user id
		table_to_be_moved=User.reflect_on_all_associations(:has_many)
        .map { |assoc| assoc.name} - [:attend_events, :follow_events ] #- [ :normal_scores , :agree_scores#, :attend_events, :follow_events ]
    table_to_be_moved.each do |table_name|
			puts table_name
      self.send(table_name).update_all(:user_id=>new_user.id)
    end
    self.destroy!
  end

  def has_imported?
    return self.agree
  end

## social auth   
  def hasFb?
    return self.auth_facebook.present?
  end
  
  def hasGoogle?
    return self.auth_google.present?
  end
  
  def hasSocialAuth?
    return (self.hasFb? || self.hasGoogle?)
  end
  
  def hasE3?
    return self.auth_e3.present?
  end

  def hasNctu?
    return self.auth_nctu.present? || self.hasE3?
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
    taked=self.courses_taked.map{|cs|#.order("id ASC")
      cs.to_stat_json
    }
    agreed=self.courses_agreed.map{|cs|#.order("course_field_id DESC")
      cs.to_stat_json
    }
    return (taked+agreed)#.sort_by{|x|x[:cf_id]}.reverse
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
    user.password = Devise.friendly_token[0,20] # random
    user.save!
    return user
  end
end
