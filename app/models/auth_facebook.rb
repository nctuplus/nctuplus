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
      
      # the fb info belongs to somebody
      if f.user_id  
      	# user would like to bind e3 to fb
        if current_user.try(:hasE3?) and not current_user.try(:hasFB?)
        	# ensure the binded user is fb-only user
        	fb_user = f.user
        	if not fb_user.hasE3?
						old_user = f.user
						f.user.merge_child_to_newuser(current_user) # merge to e3 user (main e3)
						f.user_id = current_user.id  
						old_user.destroy
					else
						return {:auth=>false, :message=>"此FB登錄資訊已有人使用，請檢查是否有共用問題"}
					end	
				else
					# regular fb login	
				end
      else # new auth fb user 
				if current_user # new auth fb and login as e3
          f.user_id = current_user.id # bind new fb to e3 user
        else
          user = User.create_from_auth({
            :name=>auth.info.name,
            :email=>auth.info.email, # 
            :password=>Devise.friendly_token[0,20]
          })
          f.user_id = user.id
        end
      end
      f.save!
    end
    return {:auth=>true, :user=>auth_facebook.user} 
  end
  
end
