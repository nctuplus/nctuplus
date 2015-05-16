class AuthFacebook < ActiveRecord::Base
  belongs_to :user
  
  
  def to_json
    {
      :uid=>self.uid,
      :name=>self.name,
      :email=>self.email
    }
  end
  
  def self.from_omniauth(auth, current_user)
    auth_facebook = where(auth.slice(:uid)).first_or_initialize.tap do |f|
      f.uid = auth.uid
      f.name = auth.info.name
      f.oauth_token = auth.credentials.token
      f.oauth_expires_at = Time.at(auth.credentials.expires_at)
      f.email = auth.info.email
      
      if not f.user_id 
        if not current_user.presence
          user = User.create_from_auth({
            :provider=>"facebook",
            :name=>auth.info.name,
            :email=>"#{Devise.friendly_token[0,8]}@please.change.me",#auth.info.email,
            :password=>Devise.friendly_token[0,20]
          })
          f.user_id = user.id
        else
          f.user_id = current_user.id # binding
        end
      elsif f.user_id and current_user # 已登入但要bind一個使用過的auth
        return {:auth=>false, :message=>"此認證帳號已被使用"}
      end
      
      f.save!
    end
    return {:auth=>true, :user=>auth_facebook.user} 
  end
  
end
