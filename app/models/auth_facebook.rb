class AuthFacebook < ActiveRecord::Base
  belongs_to :user
  
  # for session[:auth_facebook] 
  def to_json
    {
      :uid=>self.uid,
      :name=>self.name,
      :email=>self.email,
   #   :avatar_url=>"https://graph.facebook.com/#{self.uid}/picture",
   #   :webpage_url=>"https://www.facebook.com/#{self.uid}"
    }
  end
  
  def self.from_omniauth(auth)
    auth_facebook = where(auth.slice(:uid)).first_or_initialize.tap do |f|
      f.uid = auth.uid
      f.name = auth.info.name
      f.oauth_token = auth.credentials.token
      f.oauth_expires_at = Time.at(auth.credentials.expires_at)
      f.email = auth.info.email
          
      f.save!
    end
    return auth_facebook
  end
  
end
