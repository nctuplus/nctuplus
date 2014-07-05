class User < ActiveRecord::Base
  has_many :file_infos
  has_many :posts
  has_many :courses, :through=> :course_manager
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
	  
	  if user.activated.nil?
	    user.grade_id = 1
	    user.email = "not register yet"
	    user.activated = 0
	  end
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end
end