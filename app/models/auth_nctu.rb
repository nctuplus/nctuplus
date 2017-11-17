class AuthNctu < ApplicationRecord
  belongs_to :user

  def to_session_json
    return {
      :student_id => self.student_id,
      :email => self.email
    }
  end

  def self.from_omniauth(auth)
    auth_nctu = where(student_id: auth.extra.raw_info.username).first_or_initialize.tap do |n|
      n.student_id  = auth.extra.raw_info.username
      n.email       = auth.extra.raw_info.email
      n.oauth_token = auth.credentials.token
      n.oauth_expires_at = Time.now.since(10.hour)
      if n.user_id.nil?
        authE3 = AuthE3.where(student_id: auth.extra.raw_info.username).first
        if authE3.present?
          n.user_id = authE3.user_id
        else
          n.user_id = User.create_from_auth({
            :name=>auth.extra.raw_info.username,
            :email=>auth.extra.raw_info.email
          }).id
        end  
      end
      n.save!
    end
    return auth_nctu
  end
end
