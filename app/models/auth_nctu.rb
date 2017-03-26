class AuthNctu < ActiveRecord::Base
  belongs_to :user

  def to_session_json
    return {
      :student_id => self.student_id,
      :email => self.email
    }
  end

  def self.from_omniauth(auth)
    auth_nctu = where(student_id: auth.extra.profile.username).first_or_initialize.tap do |n|
      n.student_id  = auth.extra.profile.username
      n.email       = auth.extra.profile.email
      n.oauth_token = auth.credentials.token
      n.oauth_expires_at = Time.now.since(10.hour)
      if n.user_id.nil?
        authE3 = AuthE3.where(student_id: auth.extra.profile.username).first
        if authE3.present?
          n.user_id = authE3.user_id
        else
          n.user_id = User.create_from_auth({
            :name=>auth.extra.profile.username,
            :email=>auth.extra.profile.email
          }).id
        end  
      end
      n.save!
    end
    return auth_nctu
  end
end
