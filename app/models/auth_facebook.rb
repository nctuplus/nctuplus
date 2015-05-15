class AuthFacebook < ActiveRecord::Base
  belongs_to :user
  
  def self.from_omniauth(auth)
    auth_facebook = where(auth.slice(:uid)).first_or_initialize.tap do |f|
      f.uid = auth.uid
      f.name = auth.info.name
      f.oauth_token = auth.credentials.token
      f.oauth_expires_at = Time.at(auth.credentials.expires_at)
      f.email = auth.info.email
      
      unless f.user_id
        user = User.create_from_auth({
          :provider=>"facebook",
          :name=>auth.info.name,
          :email=>"#{Devise.friendly_token[0,8]}@please.change.me",#auth.info.email,
          :password=>Devise.friendly_token[0,20]
        })
        f.user_id = user.id
      end
      
      f.save!
    end
    return auth_facebook.user 
  end
  
end
