class AuthGoogle < ActiveRecord::Base
  belongs_to :user
  
  # for session[:auth_google] 
  def to_json
    {
      :uid=>self.uid,
      :name=>self.name,
      :email=>self.email,
   #   :avatar_url=>self.image_url,
  #    :webpage_url=>"https://www.google.com/#{self.uid}"
    }
  end
  
  def self.from_omniauth(auth) 
    auth_google = where(auth.slice(:uid)).first_or_initialize.tap do |f|
      f.uid = auth.uid
      f.name = auth.info.name
      f.email = auth.info.email
      f.image_url = auth.info.image
      f.gender = auth.extra.raw_info.try(:gender)
      f.birthday = auth.extra.raw_info.try(:birthday)
      f.location = auth.extra.raw_info.try(:locale)
      
      f.oauth_token = auth.credentials.token
      f.oauth_expires_at = Time.at(auth.credentials.expires_at)
      
      f.save!
    end
    return auth_google 
  end
  
end
